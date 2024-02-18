import Foundation

struct AuthData {
    let sessionId: String
    let token: String
}

struct DebugMenuModel {
    let endpoint: ApiEndpoint
    let authData: AuthData
}

protocol IDebugMenuPresenter: AnyObject {
    func onSaveButtonTappped(with model: ApiEndpoint)
    func onSaveButtonTappped(with model: DebugMenuModel)
    func onViewReady()
}

protocol IDebugMenuView {
    func setView(with model: ApiEndpoint)
    func setView(with model: DebugMenuModel)
}
