import Foundation

enum RequestBuilderError: Error {
    case error
}

protocol IRequestBuilder: AnyObject {
    func build(request: IRequest) throws -> URLRequest
}

final class RequestBuilder: IRequestBuilder {
    
    private let sessionProvider: ISessionProvider
    
    init(sessionProvider: ISessionProvider) {
        self.sessionProvider = sessionProvider
    }
    
    func build(request: IRequest) throws -> URLRequest {
        let fullPath = "http://" + request.domain() + request.path()
        
        guard let url = URL(string: fullPath) else {
            throw RequestBuilderError.error
        }
        
        var httpHeaderFields = request.httpHeaderFields()
        
        switch request.authorizationType() {
        case .token:
            httpHeaderFields["Authorization"] = sessionProvider.token
        case .session:
            break
        case .none:
            break
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.type().rawValue
        urlRequest.httpBody = request.httpBodyData()
        urlRequest.allHTTPHeaderFields = httpHeaderFields
        
        return urlRequest
    }
}
