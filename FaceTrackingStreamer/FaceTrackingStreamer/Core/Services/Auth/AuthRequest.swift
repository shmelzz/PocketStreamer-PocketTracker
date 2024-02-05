import Foundation

struct AuthRequest: Encodable {
    let username: String
    let password: String
}

struct LoginResponse: Decodable {
    let token: String
}

struct RegisterResponse: Decodable {}
