import UIKit
import ARKit
import Network
import Starscream

final class FaceTrackingViewController: UIViewController {
    
    private let endpointStorage: IApiEndpointStorage
    
    private var websocket: WebSocket!
    
    private var sceneView: ARSCNView!
    private var faceNode: SCNNode!
    
    private var isWebsocketConnected: Bool = false
    
    private let connectButton = UIButton(type: .system)
    
    // MARK: Init
    
    init(
        endpointStorage: IApiEndpointStorage
    ) {
        self.endpointStorage = endpointStorage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
        setupARFaceTracking()
        setupConnectButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        connectButtonTapped()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: Private
    
    private func setupConnectButton() {
        connectButton.backgroundColor = .gray
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
        connectButton.layer.cornerRadius = 10
        
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            connectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    @objc
    private func connectButtonTapped() {
        let endpointModel = endpointStorage.get()
        presentWebSocketConfigAlert(with: endpointModel)
    }

    private func presentWebSocketConfigAlert(with currentConfig: ApiEndpoint?) {
        let alertController = UIAlertController(title: "WebSocket Configuration", message: "Enter WebSocket address and port", preferredStyle: .alert)
        
        // TODO: refactor
        
        if let model = currentConfig {
            alertController.addTextField { textField in
                textField.text = model.endpoint
            }
            
            alertController.addTextField { textField in
                textField.text = model.port
                textField.keyboardType = .numberPad
            }
        } else {
            alertController.addTextField { textField in
                textField.placeholder = "Enter address (e.g., 192.168.0.8)"
            }
            
            alertController.addTextField { textField in
                textField.placeholder = "Enter port (e.g., 12345)"
                textField.keyboardType = .numberPad
            }
        }
        
        let connectAction = UIAlertAction(title: "Connect", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let address = alertController.textFields?[0].text ?? ""
            let port = alertController.textFields?[1].text ?? ""
            
            var addressPort = ""
            if !address.isEmpty && !port.isEmpty {
                endpointStorage.set(ApiEndpoint(endpoint: address, port: port))
                addressPort = "ws://\(address):\(port)/facetracking"
            } else {
                addressPort = "ws://192.168.31.186:3000/facetracking"
            }
            self.setupWebSocketConnection(url: addressPort)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(connectAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
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
        request.timeoutInterval = 5
        websocket = WebSocket(request: request)
        websocket.delegate = self
        websocket.connect()
    }
    
    private func sendDataToOtherDevice(faceTrackingData: [String: Any]) {
        guard let websocket = websocket else {
            return
        }
        
        print(faceTrackingData)
        
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

extension FaceTrackingViewController: WebSocketDelegate {
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
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


extension FaceTrackingViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                processFaceMotionData(faceAnchor: faceAnchor)
            }
        }
    }
}

extension FaceTrackingViewController: ARSCNViewDelegate {
    
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
