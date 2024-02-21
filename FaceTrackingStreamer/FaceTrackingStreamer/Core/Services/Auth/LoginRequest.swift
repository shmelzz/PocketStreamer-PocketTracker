import Foundation

struct LoginResponse: Decodable, JSONParsable {
    let token: String
}

final class LoginRequest: CoreRequest, IJSONRequest {
    
    let username: String
    let password: String
    
    init(
        username: String,
        password: String,
        endpoint: String
    ) {
        self.username = username
        self.password = password
        super.init(endpoint: endpoint)
    }
    
    typealias ResponseModel = LoginResponse
    
    override func type() -> RequestType {
        .GET
    }
    
    override func path() -> String {
        "/auth/login"
    }
}
