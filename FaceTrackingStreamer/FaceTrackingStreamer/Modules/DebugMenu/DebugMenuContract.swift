import Foundation

struct DebugMenuModel {
    let environments: Environments?
    let authData: AuthData?
}

protocol IDebugMenuPresenter: AnyObject {
    func onViewReady()
    func onSaveButtonTappped(with model: DebugMenuModel)
}

protocol IDebugMenuView {
    func setView(with model: DebugMenuModel)
}
