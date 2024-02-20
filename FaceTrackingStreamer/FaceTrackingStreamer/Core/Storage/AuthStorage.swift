import Foundation

struct AuthData: UserDefaultsStorable {
    
    static let key = "authData"
    
    let sessionId: String
    let token: String
}

protocol IAuthStorage: AnyObject {
    func get() -> AuthData?
    func set(_ value: AuthData?)
}

final class AuthStorageDefaults: UserDefaultsStorage<AuthData>, IAuthStorage { }

// TODO with keychain

// final class AuthStorage: IAuthStorage {}

