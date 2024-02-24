import UIKit
import ARKit
import Network
import Starscream

final class OldFaceTrackingViewController: UIViewController {
    
    private let endpointStorage: IApiEndpointStorage
    private let authStorage: ISessionStorage
    
    private var websocket: WebSocket!
    
    private var sceneView: ARSCNView!
    private var faceNode: SCNNode!
    
    private var isWebsocketConnected: Bool = false
    
    private lazy var vc = DebugMenuViewController()
    private lazy var presenter = DebugMenuPresenter(
        endpointStorage: endpointStorage,
        authStorage: authStorage,
        view: vc,
        co
    )

    private lazy var connectButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Connect", for: .normal)
        button.addTarget(self, action: #selector(onConnectTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(onSettingsTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: Init
    
    init(
        endpointStorage: IApiEndpointStorage,
        authStorage: ISessionStorage
    ) {
        self.endpointStorage = endpointStorage
        self.authStorage = authStorage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupARFaceTracking()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // connectButtonTapped()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: Private
    
    private func setupView() {
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            connectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    @objc
    private func onSettingsTapped() {
        vc.presenter = presenter
        present(vc, animated: true)
    }
    
    @objc
    private func onConnectTapped() {
        guard let envs = endpointStorage.get() else { return }
        let endpoint = envs.environments.first(where: { $0.isSelected })
        
        guard let urlAddress = endpoint?.endpoint.endpoint,
              let port = endpoint?.endpoint.port
        else { return }
        
        let address = "ws://\(urlAddress):\(port)/facetracking"
        
        self.setupWebSocketConnection(url: address)
    }
    
    @objc
    private func connectButtonTapped() {
        // let endpointModel = endpointStorage.get()
        vc.presenter = presenter
        // presentWebSocketConfigAlert(with: endpointModel)
        present(vc, animated: true)
    }
    
    private func setupSceneView() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(sceneView)
        
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        
        let faceGeometry = ARSCNFaceGeometry(device: sceneView.device!)
        faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.fillMode = .lines
    }
    
    
    private func setupARFaceTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("ARFaceTrackingConfiguration is not supported on this device")
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
    }
    
    private func setupWebSocketConnection(url: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 10
        websocket = WebSocket(request: request)
        websocket.delegate = self
        websocket.connect()
    }
    
    private func sendDataToOtherDevice(faceTrackingData: [String: Any]) {
        guard let websocket = websocket else {
            return
        }
        
        if !isWebsocketConnected {
            return
        }
        guard let jsonData = try? JSONSerialization.data(withJSONObject: faceTrackingData, options: []) else {
            print("Error encoding face tracking data")
            return
        }
        websocket.write(data: jsonData)
    }
    
    private func processFaceMotionData(faceAnchor: ARFaceAnchor) {
        // Extract eye, nose, and mouth movement data
        let faceTrackingData = faceAnchor.eyeNoseMouthData
        
        // Send face tracking data to the other device
        sendDataToOtherDevice(faceTrackingData: faceTrackingData)
    }
}

extension OldFaceTrackingViewController: WebSocketDelegate {
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            connectButton.backgroundColor = .green
            print("WebSocket connected")
            isWebsocketConnected = true
            guard let jsonData = try? JSONSerialization.data(withJSONObject: ["leftEye":[1.2], "rightEye":[2.3], "geometry":[1]], options: []) else {
                print("Error encoding face tracking data")
                return
            }
            guard let websocket = websocket else {
                return
            }
            websocket.write(data: jsonData)
        case .disconnected(let reason, let code):
            connectButton.backgroundColor = .gray
            print("WebSocket disconnected: \(reason)")
            isWebsocketConnected = false
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
            connectButton.backgroundColor = .red
            print("WebSocket cancelled")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .peerClosed:
            print()
        }
    }
}

extension OldFaceTrackingViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                processFaceMotionData(faceAnchor: faceAnchor)
            }
        }
    }
}

extension OldFaceTrackingViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARFaceAnchor {
            node.addChildNode(faceNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor {
            let faceGeometry = faceNode.geometry as? ARSCNFaceGeometry
            faceGeometry?.update(from: faceAnchor.geometry)
        }
    }
}
