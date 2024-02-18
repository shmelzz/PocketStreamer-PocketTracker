import Foundation

struct AuthRequest: IRequest {
    let username: String
    let password: String
}

struct LoginResponse: IResponse {
    let token: String
}

struct RegisterResponse: Decodable {}
