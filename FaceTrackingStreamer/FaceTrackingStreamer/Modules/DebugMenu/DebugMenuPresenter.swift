import Foundation

final class DebugMenuPresenter: IDebugMenuPresenter {
    
    // MARK: DI
    
    private let endpointStorage: IApiEndpointStorage
    private let view: IDebugMenuView
    
    init(
        endpointStorage: IApiEndpointStorage,
        view: IDebugMenuView
    ) {
        self.endpointStorage = endpointStorage
        self.view = view
    }
    
    // MARK: IDebugMenuPresenter
    
    func onSaveButtonTappped(with model: ApiEndpoint) {
        endpointStorage.set(model)
    }
    
    func onViewReady() {
        guard let model = endpointStorage.get() else { return }
        view.setView(with: model)
    }
}
