import Foundation

final class AuthPresenter: BaseModuleOutput, IAuthPresenter {
    
    // MARK: - DI
    
    private let authService: IAuthService
    
    init(
        authService: IAuthService,
        coordinator: ICoordinator
    ) {
        self.authService = authService
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IAuthPresenter
    
    func onLoginButtonTapped(with model: AuthModel) {
        authService.login(with: model) { [weak self] result in
            switch result {
            case .success(let data):
                self?.finish(.loginDidSuccessed)
            case .failure(_):
                break
            }
        }
    }
    
    func onRegisterButtonTapped(with model: AuthModel) {
        authService.register(with: model) { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(_):
                break
            }
        }
    }
}
