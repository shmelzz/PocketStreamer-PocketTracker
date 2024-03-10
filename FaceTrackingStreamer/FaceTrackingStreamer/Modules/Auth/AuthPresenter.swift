import Foundation

final class AuthPresenter: BaseModuleOutput, IAuthPresenter {
    
    // MARK: - DI
    
    private weak var view: IAuthView?
    private let authService: IAuthService
    private let sessionStorage: ISessionStorage
    private let sessionProvider: ISessionProvider
    
    init(
        view: IAuthView,
        authService: IAuthService,
        sessionStorage: ISessionStorage,
        sessionProvider: ISessionProvider,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.authService = authService
        self.sessionStorage = sessionStorage
        self.sessionProvider = sessionProvider
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IAuthPresenter
    
    func onViewReady() {
        authService.validate() { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
                self?.finish(.loginDidSuccessed)
            case .failure(_):
                break
            }
        }
    }
    
    func onLoginButtonTapped(with model: AuthModel) {
        authService.login(with: model) { [weak self] result in
            switch result {
            case .success(let data):
                self?.sessionStorage.set(AuthData(sessionId: "1", token: data.token))
                self?.sessionProvider.token = data.token
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
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
