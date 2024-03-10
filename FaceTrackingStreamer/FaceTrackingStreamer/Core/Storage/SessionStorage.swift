import Foundation

struct AuthData: UserDefaultsStorable {
    
    static let key = "authData"
    
    let sessionId: String
    let token: String
}

protocol ISessionStorage: AnyObject {
    func get() -> AuthData?
    func set(_ value: AuthData?)
}

final class SessionStorage: UserDefaultsStorage<AuthData>, ISessionStorage { }

// TODO with keychain

// final class AuthStorage: IAuthStorage {}

