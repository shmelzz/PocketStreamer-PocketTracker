import Foundation

final class DebugMenuPresenter: BaseModuleOutput, IDebugMenuPresenter {
    
    // MARK: - DI
    
    private let endpointStorage: IApiEndpointStorage
    private let authStorage: ISessionStorage
    private let sessionProvider: ISessionProvider
    private let endpointProvider: IEndpointProvider
    
    private weak var view: IDebugMenuView?
    
    init(
        endpointStorage: IApiEndpointStorage,
        authStorage: ISessionStorage,
        sessionProvider: ISessionProvider,
        endpointProvider: IEndpointProvider,
        view: IDebugMenuView,
        coordinator: ICoordinator
    ) {
        self.endpointStorage = endpointStorage
        self.authStorage = authStorage
        self.sessionProvider = sessionProvider
        self.endpointProvider = endpointProvider
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    // MARK: IDebugMenuPresenter
    
    func onSaveButtonTappped(with model: DebugMenuModel) {
        endpointStorage.set(model.environments)
        authStorage.set(model.authData)
    }
    
    func onViewReady() {
        let data = endpointStorage.get()
        var endpointsModel: Environments
        if let models = data {
            endpointsModel = models
        } else {
            let hosts = endpointProvider.domains()
            endpointsModel = Environments(
                environments: [
                    EnvironmentEndpoint(
                        environment: .prod,
                        endpoint: ApiEndpoint(endpoint: hosts[.prod] ?? "", port: ""),
                        isSelected: false
                    ),
                    EnvironmentEndpoint(
                        environment: .test,
                        endpoint: ApiEndpoint(endpoint: hosts[.test] ?? "", port: ""),
                        isSelected: true
                    )
                ]
            )
        }
        
        let authModel = AuthData(sessionId: sessionProvider.sessionId ?? "", token: sessionProvider.token ?? "")
        
        let viewModel = DebugMenuModel(environments: endpointsModel, authData: authModel)
        
        view?.setView(with: viewModel)
    }
}
