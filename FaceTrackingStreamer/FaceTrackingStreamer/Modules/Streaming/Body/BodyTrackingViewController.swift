import UIKit
import RealityKit
import ARKit
import Combine

import Network
import Starscream

final class BodyTrackingViewController: UIViewController, IBodyTrackingView, ARSessionDelegate {
    
    private let arView: ARView
    
    private lazy var connectionStatusImageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.undefined)
        return view
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton.tinted(
            title: "Connect",
            font: Fonts.redditMonoSemiBold
        )
        button.tintColor = .black
        button.addTarget(self, action: #selector(onConnectTapped), for: .touchUpInside)
        return button
    }()
    
    var character: BodyTrackedEntity?
    let characterOffset: SIMD3<Float> = [-0.5, 0, 0]
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
        
        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(connectionStatusImageView)
        connectionStatusImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectionStatusImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            connectionStatusImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            connectionStatusImageView.heightAnchor.constraint(equalToConstant: 52),
            connectionStatusImageView.widthAnchor.constraint(equalToConstant: 52)
        ])
        
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            connectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arView.session.delegate = self
        
        guard ARBodyTrackingConfiguration.isSupported else {
            fatalError("This feature is only supported on devices with an A12 chip")
        }
        
        let configuration = ARBodyTrackingConfiguration()
        arView.session.run(configuration)
        
        arView.scene.addAnchor(characterAnchor)
        
        var cancellable: AnyCancellable? = nil
        
        cancellable = Entity.loadBodyTrackedAsync(named: "robot").sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error: Unable to load model: \(error.localizedDescription)")
                }
                cancellable?.cancel()
        }, receiveValue: { (character: Entity) in
            if let character = character as? BodyTrackedEntity {
                character.scale = [1.0, 1.0, 1.0]
                self.character = character
                cancellable?.cancel()
            } else {
                print("Error: Unable to load model as BodyTrackedEntity")
            }
        })
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
        request.timeoutInterval = 10
        websocket = WebSocket(request: request)
        websocket.delegate = self
        websocket.connect()
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            guard let bodyAnchor = anchor as? ARBodyAnchor else { continue }
            
            processFaceMotionData(anchor: bodyAnchor)
            
            let bodyPosition = simd_make_float3(bodyAnchor.transform.columns.3)
            characterAnchor.position = bodyPosition + characterOffset
            characterAnchor.orientation = Transform(matrix: bodyAnchor.transform).rotation
   
            if let character = character, character.parent == nil {
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
            connectButton.tintColor = .systemGreen
            connectionStatusImageView.image = ImageAssets.net
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason)")
            connectButton.tintColor = .systemRed
            connectionStatusImageView.image = ImageAssets.error
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
            connectButton.tintColor = .systemRed
            connectionStatusImageView.image = ImageAssets.error
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
