import Foundation

final class FaceTrackingPresenter: BaseModuleOutput, IFaceTrackingPresenter {
    
    private weak var view: IFaceTrackingView?
    
    init(
        view: IFaceTrackingView,
        coordinator: ICoordinator
    ) {
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    func onViewDidLoad() {
        
    }
}
