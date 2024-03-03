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
        .POST
    }
    
    override func path() -> String {
        "/auth/login"
    }
    
    override func httpBodyData() -> Data? {
        let model = AuthModel(username: username, password: password)
        let data = try? JSONEncoder().encode(model)
        return data
    }
}