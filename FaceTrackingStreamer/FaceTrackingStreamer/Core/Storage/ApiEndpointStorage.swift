import Foundation

struct ApiEndpoint: UserDefaultsStorable {
    
    static let key = "apiEndpoint"
    
    let endpoint: String
    let port: String
}

protocol IApiEndpointStorage: AnyObject {
    func set(_ value: ApiEndpoint?)
    func get() -> ApiEndpoint?
}

final class ApiEndpointStorage: UserDefaultsStorage<ApiEndpoint>, IApiEndpointStorage {}
