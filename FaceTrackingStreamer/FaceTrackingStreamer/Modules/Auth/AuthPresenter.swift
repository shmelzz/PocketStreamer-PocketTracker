import Foundation

final class AuthPresenter: IAuthPresenter {
    
    // MARK: - DI
    
    private let authService: IAuthService
    private let authStorage: IAuthStorage
    
    init(
        authService: IAuthService,
        authStorage: IAuthStorage
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
