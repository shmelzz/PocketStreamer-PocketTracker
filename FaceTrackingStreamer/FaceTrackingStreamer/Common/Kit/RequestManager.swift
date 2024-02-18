import Foundation

protocol IRequest: Encodable {}

protocol IResponse: Decodable {}

protocol IRequestManager {
    func execute(_ request: IRequest)
}

final class RequestManager: IRequestManager {
    
    func execute(_ request: IRequest) {
        guard let url = URL(string: "") else { return }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
        }
    }
}
