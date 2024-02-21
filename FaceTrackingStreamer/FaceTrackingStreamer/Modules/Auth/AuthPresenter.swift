import Foundation

final class AuthPresenter: IAuthPresenter {
    
    // MARK: - DI
    
    private let authService: IAuthService
    
    init(
        authService: IAuthService
    ) {
        self.authService = authService
    }
    
    // MARK: - IAuthPresenter
    
    func onLoginButtonTapped(with model: AuthModel) {
        authService.login(with: model) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
    }
    
    func onRegisterButtonTapped(with model: AuthModel) {
        authService.register(with: model) { result in
            switch result {
            case .success(_):
                break
            case .failure(_):
                break
            }
        }
    }
}
