import Foundation

protocol IAuthPresenter: AnyObject {
    func onLoginButtonTapped(with model: AuthModel)
    func onRegisterButtonTapped(with model: AuthModel)
    func onLongPress()
}

protocol IAuthView: AnyObject { }
