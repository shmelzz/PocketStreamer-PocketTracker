import Foundation

final class AuthPresenter: IAuthPresenter {
    
    // MARK: - DI
    
    private let authService: IAuthService
    private let authStorage: ISessionStorage
    
    init(
        authService: IAuthService,
        authStorage: ISessionStorage
    ) {
        self.authService = authService
        self.authStorage = authStorage
    }
    
    // MARK: - IAuthPresenter
    
    func onLoginButtonTapped(with model: AuthModel) {
        authService.login(with: model)
    }
    
    func onRegisterButtonTapped(with model: AuthModel) {
        authService.register(with: model)
    }
}
