import UIKit
import RealityKit
import ARKit
import Combine

import Network
import Starscream

final class BodyTrackingViewController: UIViewController, IBodyTrackingView, ARSessionDelegate {
    
    private let arView: ARView
    
    // The 3D character to display.
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-0.5, 0, 0] // Offset the character by one meter to the left
    let characterAnchor = AnchorEntity()
    
    var presenter: IBodyTrackingPresenter?
    
    private let servicesAssembly: IServicesAssembly
    
    private var websocket: WebSocket!
    
    private var shouldSend: Bool = true
    
    init(
        servicesAssembly: IServicesAssembly
    ) {
        self.arView = ARView(frame: .zero)
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        // If the iOS device doesn't support body tracking, raise a developer error for
        // this unhandled case.
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }

        // Run a body tracking configration.
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        // Asynchronously load the 3D character.
        var cancellable: AnyCancellable? = nil
        
        cancellable = Entity.loadBodyTrackedAsync(named: "robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                // Scale the character to human size
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
        
        onConnectTapped()
    }
    
    @objc
    private func onConnectTapped() {
        let endpoint = servicesAssembly.endpointProvider.faceTrackingEndpoint()
        let address = "ws://\(endpoint)/bodytracking"
        
        self.setupWebSocketConnection(url: address)
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            self.shouldSend.toggle()
        }
    }
    
    private func setupWebSocketConnection(url: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.setValue(servicesAssembly.sessionProvider.token, forHTTPHeaderField: "Authentication")
        request.setValue(servicesAssembly.sessionProvider.sessionId, forHTTPHeaderField: "SessionId")
        print("sessionId: \(servicesAssembly.sessionProvider.sessionId)")
        request.timeoutInterval = 10
        websocket = WebSocket(request: request)
        websocket.delegate = self
        websocket.connect()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            processFaceMotionData(anchor: bodyAnchor)
            
            // Update the position of the character anchor's position.
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            // Also copy over the rotation of the body anchor, because the skeleton's pose
            // in the world is relative to the body anchor's rotation.
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
                // Attach the character to its anchor as soon as
                // 1. the body anchor was detected and
                // 2. the character was loaded.
                characterAnchor.addChild(character)
            }
        }
    }
    
    private func processFaceMotionData(anchor: ARBodyAnchor) {
        if shouldSend {
            let data = anchor.data
            sendDataToOtherDevice(bodyData: data)
        }
    }
    
    private func sendDataToOtherDevice(bodyData: [String: simd_float4x4]) {
        guard let websocket = websocket else {
            return
        }

        guard let jsonData = try? JSONEncoder().encode(bodyData) else {
            print("Error encoding face tracking data")
            return
        }
        
        websocket.write(data: jsonData)
    }
}

extension BodyTrackingViewController: WebSocketDelegate {
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            print("WebSocket connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason)")
        case .text(let text):
            print("Received text: \(text)")
        case .binary(let data):
            print("Received data: \(data)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("WebSocket cancelled")
        case .error(let error):
            let alert = UIAlertController(
                title: "Error",
                message: error?.localizedDescription ?? "Unknown error",
                preferredStyle: .alert
            )
            
            let alertOKAction = UIAlertAction(
                title:"OK",
                style: .default,
                handler: { [weak self] _ in
                    self?.dismiss(animated: true)
            })
            
            alert.addAction(alertOKAction)
            present(alert, animated: true)
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .peerClosed:
            print()
        }
    }
}
