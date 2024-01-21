import Foundation
import Starscream

protocol IFaceTrackingService {
    func send(facetrackingData: [String: Any])
}

protocol IFaceTrackingServiceDelegate: AnyObject {
    func didReceive()
}

final class FaceTrackingService: IFaceTrackingService {
    
    private let webSocket: WebSocket
    
    weak var delegate: IFaceTrackingServiceDelegate?
    
    init(
        webSocket: WebSocket,
        delegate: IFaceTrackingServiceDelegate
    ) {
        self.webSocket = webSocket
        self.delegate = delegate
    }
    
    // MARK: - IFaceTrackingService
    
    func send(facetrackingData: [String : Any]) {
        
    }
    
    
}
