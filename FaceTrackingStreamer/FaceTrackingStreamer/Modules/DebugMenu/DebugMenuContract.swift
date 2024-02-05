import Foundation

struct DebugMenuModel {
    let endpoint: ApiEndpoint
}

protocol IDebugMenuPresenter: AnyObject {
    func onSaveButtonTappped(with model: ApiEndpoint)
    func onViewReady()
}

protocol IDebugMenuView {
    func setView(with model: ApiEndpoint)
}
