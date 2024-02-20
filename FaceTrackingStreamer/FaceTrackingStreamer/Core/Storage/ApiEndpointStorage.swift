import Foundation

struct ApiEndpoint: Codable {
    let endpoint: String
    let port: String
}

struct EnvironmentEndpoint: Codable {
    let environment: EnvironmentType
    let endpoint: ApiEndpoint
    let isSelected: Bool
    
    enum EnvironmentType: Codable {
        case prod
        case test
    }
}

struct Environments: UserDefaultsStorable {
    static let key = "environmentKeys"
    
    let environments: [EnvironmentEndpoint]
}

protocol IApiEndpointStorage: AnyObject {
    func set(_ value: Environments?)
    func get() -> Environments?
}

final class ApiEndpointStorage: UserDefaultsStorage<Environments>, IApiEndpointStorage {}
