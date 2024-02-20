import Foundation

protocol IRequestBuilder: AnyObject {
    func build(request: IRequest) throws -> URLRequest
}

final class RequestBuilder: IRequestBuilder {
    
    private let sessionStorage: ISessionStorage
//    private let environmentProvider:
    
    init(
        sessionStorage: ISessionStorage
    ) {
        self.sessionStorage = sessionStorage
    }
    
    func build(request: IRequest) throws -> URLRequest {
        
    }
}
