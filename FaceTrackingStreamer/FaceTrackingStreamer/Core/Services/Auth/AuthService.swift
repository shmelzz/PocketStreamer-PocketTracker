import Foundation

struct AuthModel {
    let username: String
    let password: String
}

protocol IAuthService {
    func login(with model: AuthModel)
    func register(with model: AuthModel)
}

final class AuthService: IAuthService {
    
    private enum Constants {
        static let loginEndpoint = "auth/login"
        static let registerEndpoint = "auth/register"
    }
    
    private let requestManager: IRequestManager
    private let authCredentialsStorage: KeychainWrapper
    
    init(
        requestManager: IRequestManager,
        authCredentialsStorage: KeychainWrapper = .defaultKeychainWrapper
    ) {
        self.requestManager = requestManager
        self.authCredentialsStorage = authCredentialsStorage
    }
    
    
    func login(with model: AuthModel) {
        let request = AuthRequest(username: model.username, password: model.password)
    }
    
    func register(with model: AuthModel) {
        let request = AuthRequest(username: model.username, password: model.password)
    }
}


