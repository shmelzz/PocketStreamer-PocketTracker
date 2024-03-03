import Foundation

final class DebugMenuPresenter: BaseModuleOutput, IDebugMenuPresenter {
    
    // MARK: - DI
    
    private let endpointStorage: IApiEndpointStorage
    private let authStorage: ISessionStorage
    private weak var view: IDebugMenuView?
    
    init(
        endpointStorage: IApiEndpointStorage,
        authStorage: ISessionStorage,
        view: IDebugMenuView,
        coordinator: ICoordinator
    ) {
        self.endpointStorage = endpointStorage
        self.authStorage = authStorage
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    // MARK: IDebugMenuPresenter
    
    func onSaveButtonTappped(with model: DebugMenuModel) {
        endpointStorage.set(model.environments)
        authStorage.set(model.authData)
    }
    
    func onViewReady() {
        let endpointsModel = endpointStorage.get()
        let authModel = authStorage.get()
        let viewModel = DebugMenuModel(environments: endpointsModel, authData: authModel)
        
        view?.setView(with: viewModel)
    }
}
