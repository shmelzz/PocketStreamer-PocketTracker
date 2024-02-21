import Foundation

struct RegisterResponse: Decodable, JSONParsable {}

final class RegisterRequest: CoreRequest, IJSONRequest {
    
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
    
    typealias ResponseModel = RegisterResponse
    
    override func type() -> RequestType {
        .GET
    }
    
    override func path() -> String {
        "/auth/register"
    }
}
