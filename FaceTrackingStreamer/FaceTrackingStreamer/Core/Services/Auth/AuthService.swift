import Foundation

struct AuthModel {
    let username: String
    let password: String
}

protocol IAuthService {
    func login(with model: AuthModel, completion: @escaping (Result<LoginResponse, Error>) -> Void)
    func register(with model: AuthModel, completion: @escaping (Result<RegisterResponse, Error>) -> Void)
}

final class AuthService: IAuthService {

    private let requestManager: IRequestManager
    private let endpointProvider: IEndpointProvider
    
    init(
        requestManager: IRequestManager,
        endpointProvider: IEndpointProvider
    ) {
        self.requestManager = requestManager
        self.endpointProvider = endpointProvider
    }
    
    func login(with model: AuthModel, completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let request = LoginRequest(
            username: model.username,
            password: model.password,
            endpoint: endpointProvider.endpoint()
        )
        requestManager.execute(request: request, completion: completion)
    }
    
    func register(with model: AuthModel, completion: @escaping (Result<RegisterResponse, Error>) -> Void) {
        let request = RegisterRequest(
            username: model.username,
            password: model.password,
            endpoint: endpointProvider.endpoint()
        )
        requestManager.execute(request: request, completion: completion)
    }
}


