import Foundation

enum RequestType: String {
    case POST
    case PUT
    case GET
    case DELETE
}

enum AuthorizationType {
    case token
    case session
    case none
}

protocol IRequest: AnyObject {
    
    func type() -> RequestType
    
    func domain() -> String
    
    func path() -> String
    
    func httpBodyData() -> Data?
    
    func parametres() -> [String:String]
    
    func httpHeaderFields() -> [String:String]
    
    func authorizationType() -> AuthorizationType
}
