import ARKit

final class FaceTrackingPresenter: BaseModuleOutput, IFaceTrackingPresenter, ARSessionDelegate {
    
    private let endpointStorage: IApiEndpointStorage
    private let endpointProvider: IEndpointProvider
    private let authStorage: ISessionStorage
    private let sessionProvider: ISessionProvider
    private let actionsService: IActionsService
    private let chatService: IChatService
    private let platformManager: IPlatformManager
    private let faceTrackingService: IFaceTrackingService
    
    private weak var view: IFaceTrackingView?
    
    init(
        endpointStorage: IApiEndpointStorage,
        endpointProvider: IEndpointProvider,
        authStorage: ISessionStorage,
        sessionProvider: ISessionProvider,
        actionsService: IActionsService,
        chatService: IChatService,
        platformManager: IPlatformManager,
        faceTrackingService: IFaceTrackingService,
        view: IFaceTrackingView,
        coordinator: ICoordinator
    ) {
        self.endpointStorage = endpointStorage
        self.endpointProvider = endpointProvider
        self.authStorage = authStorage
        self.sessionProvider = sessionProvider
        self.actionsService = actionsService
        self.chatService = chatService
        self.platformManager = platformManager
        self.faceTrackingService = faceTrackingService
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IFaceTrackingPresenter
    
    func onViewDidLoad() {
        
    }
    
    func onConnectTapped() {
        faceTrackingService.connect()
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                processFaceMotionData(faceAnchor: faceAnchor)
            }
        }
    }
    
    private func processFaceMotionData(faceAnchor: ARFaceAnchor) {
        let faceTrackingData = faceAnchor.eyeNoseMouthData
        faceTrackingService.send(faceTrackingData)
    }
}
