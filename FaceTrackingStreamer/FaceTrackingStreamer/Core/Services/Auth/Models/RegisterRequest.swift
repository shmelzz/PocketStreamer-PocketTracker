import Foundation

struct RegisterResponse: Decodable, JSONParsable {
    let message: String
}

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
        .POST
    }
    
    override func path() -> String {
        "/auth/register"
    }
    
    override func httpBodyData() -> Data? {
        let model = AuthModel(username: username, password: password)
        let data = try? JSONEncoder().encode(model)
        return data
    }
}
