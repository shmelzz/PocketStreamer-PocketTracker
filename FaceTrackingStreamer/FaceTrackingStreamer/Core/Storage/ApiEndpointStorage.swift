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

// MARK: - new

struct EnvironmentStorage: UserDefaultsStorable {
    static let key = "environmentKeys"
    
    let environments: [EnvironmentEndpoint]
}

struct EnvironmentEndpoint: Codable {
    let environment: EnvironmentType
    let endpoint: String
    let port: String
    
    enum EnvironmentType: Codable {
        case debug
        case release
    }
}
