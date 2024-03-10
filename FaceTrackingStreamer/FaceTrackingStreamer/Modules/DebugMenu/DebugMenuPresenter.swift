import Foundation

final class DebugMenuPresenter: BaseModuleOutput, IDebugMenuPresenter {
    
    // MARK: - DI
    
    private let endpointStorage: IApiEndpointStorage
    private let authStorage: ISessionStorage
    private let sessionProvider: ISessionProvider
    private weak var view: IDebugMenuView?
    
    init(
        endpointStorage: IApiEndpointStorage,
        authStorage: ISessionStorage,
        sessionProvider: ISessionProvider,
        view: IDebugMenuView,
        coordinator: ICoordinator
    ) {
        self.endpointStorage = endpointStorage
        self.authStorage = authStorage
        self.sessionProvider = sessionProvider
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
        
        let authModel = AuthData(sessionId: sessionProvider.sessionId ?? "", token: sessionProvider.token ?? "")
        let viewModel = DebugMenuModel(environments: endpointsModel, authData: authModel)
        
        view?.setView(with: viewModel)
    }
}
