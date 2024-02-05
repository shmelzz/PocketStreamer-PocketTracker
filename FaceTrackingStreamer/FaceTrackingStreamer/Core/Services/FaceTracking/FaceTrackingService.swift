import Foundation
import Starscream

protocol IFaceTrackingService {
    func connect()
    func send(facetrackingData: [String: Any])
}

protocol IFaceTrackingServiceDelegate: AnyObject {
    func didReceive()
}

final class FaceTrackingService: IFaceTrackingService, WebSocketDelegate {

    private var webSocket: WebSocket?
    private let endpointProvider: IApiEndpointStorage
    
    weak var delegate: IFaceTrackingServiceDelegate?
    
    init(
        endpointProvider: IApiEndpointStorage
    ) {
        self.endpointProvider = endpointProvider
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
    
    func send(facetrackingData: [String : Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: facetrackingData, options: []) else {
            print("Error encoding face tracking data")
            return
        }
        webSocket?.write(data: data)
    }
    
    func connect() {
        guard let endpoint = endpointProvider.get() else { return }
        connect(to: endpoint)
    }
    
    // MARK: - Private
    
    private func connect(to model: ApiEndpoint) {
        guard let url = URL(string: "ws://\(model.endpoint):\(model.port)/facetracking") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
    
}
