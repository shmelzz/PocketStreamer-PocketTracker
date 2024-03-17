import Foundation

struct ApiEndpoint: Codable {
    let endpoint: String
    let port: String
}

enum EnvironmentType: Codable {
    case prod
    case test
}

struct EnvironmentEndpoint: Codable {
    let environment: EnvironmentType
    let endpoint: ApiEndpoint
    let isSelected: Bool
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
