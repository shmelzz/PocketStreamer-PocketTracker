import UIKit
import ARKit
import Network
import Starscream

final class OldFaceTrackingViewController: UIViewController, IFaceTrackingView {
    
    private let endpointStorage: IApiEndpointStorage
    private let endpointProvider: IEndpointProvider
    private let authStorage: ISessionStorage
    private let sessionProvider: ISessionProvider
    private let actionsService: IActionsService
    private let chatService: IChatService
    private let platformManager: IPlatformManager
    
    private var websocket: WebSocket!
    
    private var sceneView: ARSCNView!
    private var faceNode: SCNNode!
    
    private var isWebsocketConnected: Bool = false
    
    private lazy var vc = DebugMenuViewController()
    private lazy var presenter = DebugMenuPresenter(
        endpointStorage: endpointStorage,
        authStorage: authStorage,
        sessionProvider: sessionProvider,
        endpointProvider: endpointProvider,
        view: vc,
        coordinator: coordinator
    )
    
    private var coordinator: ICoordinator
    
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
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(onSettingsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionsCameraView: ActionsListView = {
        let view = ActionsListView()
        let presenter = ActionsPresenter(
            actionsService: actionsService,
            view: view,
            coordinator: coordinator
        )
        view.presenter = presenter
        return view
    }()
    
    private lazy var chatView: ChatView = {
        let view = ChatView()
        let presenter = ChatPresenter(
            chatService: chatService,
            platformManager: platformManager,
            view: view,
            coordinator: coordinator
        )
        chatService.setDelegate(presenter)
        view.presenter = presenter
        return view
    }()
    
    // MARK: Init
    
    init(
        endpointStorage: IApiEndpointStorage,
        authStorage: ISessionStorage,
        sessionProvider: ISessionProvider,
        actionsService: IActionsService,
        chatService: IChatService,
        platformManager: IPlatformManager,
        endpointProvider: IEndpointProvider,
        coordinator: ICoordinator
    ) {
        self.endpointStorage = endpointStorage
        self.authStorage = authStorage
        self.sessionProvider = sessionProvider
        self.actionsService = actionsService
        self.chatService = chatService
        self.platformManager = platformManager
        self.endpointProvider = endpointProvider
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSceneView()
        setupARFaceTracking()
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: Private
    
    private func setupView() {
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
        
        view.addSubview(settingsButton)
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            settingsButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        view.addSubview(actionsCameraView)
        actionsCameraView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            actionsCameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            actionsCameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            actionsCameraView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            actionsCameraView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.4)
        ])
        
        view.addSubview(chatView)
        chatView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            chatView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            chatView.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -8),
            chatView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.45)
        ])
        chatView.presenter?.onViewReady()
    }
    
    @objc
    private func onSettingsTapped() {
        vc.presenter = presenter
        present(vc, animated: true)
    }
    
    @objc
    private func onConnectTapped() {
        let endpoint = endpointProvider.faceTrackingEndpoint()
        let address = "ws://\(endpoint)/facetracking"
        
        self.setupWebSocketConnection(url: address)
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
        request.setValue(sessionProvider.token, forHTTPHeaderField: "Authentication")
        request.setValue(sessionProvider.sessionId, forHTTPHeaderField: "SessionId")
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
            connectButton.tintColor = .systemGreen
            connectionStatusImageView.image = ImageAssets.net
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
            connectButton.tintColor = .systemRed
            connectionStatusImageView.image = ImageAssets.error
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
            connectButton.tintColor = .systemRed
            connectionStatusImageView.image = ImageAssets.error
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
