import Foundation

final class DebugMenuPresenter: IDebugMenuPresenter {
    
    // MARK: - DI
    
    private let endpointStorage: IApiEndpointStorage
    private let authStorage: IAuthStorage
    private let view: IDebugMenuView
    
    init(
        endpointStorage: IApiEndpointStorage,
        authStorage: IAuthStorage,
        view: IDebugMenuView
    ) {
        self.endpointStorage = endpointStorage
        self.authStorage = authStorage
        self.view = view
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
        
        view.setView(with: viewModel)
    }
}
