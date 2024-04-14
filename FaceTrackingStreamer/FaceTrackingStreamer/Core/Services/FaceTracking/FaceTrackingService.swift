import Foundation
import Starscream

protocol IFaceTrackingService {
    func connect()
    func send(_ facetrackingData: [String: Any])
}

protocol IFaceTrackingServiceDelegate: AnyObject {
    func didReceive()
}

final class FaceTrackingService: IFaceTrackingService, WebSocketDelegate {
    
    private let endpointProvider: IEndpointProvider
    private let sessionProvider: ISessionProvider
    
    private var webSocket: WebSocket?
    
    weak var delegate: IFaceTrackingServiceDelegate?
    
    init(
        endpointProvider: IEndpointProvider,
        sessionProvider: ISessionProvider
    ) {
        self.endpointProvider = endpointProvider
        self.sessionProvider = sessionProvider
    }
    
    // MARK: - WebSocketDelegate
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let dictionary):
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
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .peerClosed:
            print()
        }
    }
    
    // MARK: - IFaceTrackingService
    
    func send(_ facetrackingData: [String : Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: facetrackingData, options: []) else {
            print("Error encoding face tracking data")
            return
        }
        webSocket?.write(data: data)
    }
    
    func connect() {
        let endpoint = endpointProvider.faceTrackingEndpoint()
        connect(to: endpoint)
    }
    
    // MARK: - Private
    
    private func connect(to host: String) {
        guard let url = URL(string: "ws://\(host)/facetracking") else { return }
        var request = URLRequest(url: url)
        request.setValue(sessionProvider.token, forHTTPHeaderField: "Authentication")
        request.setValue(sessionProvider.sessionId, forHTTPHeaderField: "SessionId")
        request.timeoutInterval = 10
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
}
