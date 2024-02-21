import Foundation
import SwiftyJSON

protocol IResponse: Decodable {}

enum NetworkError: Error {
    case failureStatus
}

protocol IRequestManager: AnyObject {
    
    @discardableResult
    func execute<Request: IJSONRequest>(
        request: Request,
        completion: @escaping (Result<Request.ResponseModel, Error>) -> Void
    ) -> Cancelable
}

final class RequestManager: IRequestManager {
    
    private let requestBuilder: IRequestBuilder
    private let urlSession: URLSession
    
    init(
        requestBuilder: IRequestBuilder,
        urlSession: URLSession
    ) {
        self.requestBuilder = requestBuilder
        self.urlSession = urlSession
    }
    
    func execute<Request: IJSONRequest>(
        request: Request,
        completion: @escaping (Result<Request.ResponseModel, Error>) -> Void
    ) -> Cancelable  {
        let urlRequest: URLRequest
        do {
            urlRequest = try requestBuilder.build(request: request)
        } catch {
            completion(.failure(error))
            return DefaultCancelable()
        }
        
        return execute(urlRequest: urlRequest) { [weak self] result in
            switch result {
            case let .success(data):
                self?.parse(data: data, completion: completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private
    
    private func execute(
        urlRequest: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> Cancelable  {
        
        let task = urlSession.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
            } else if let response = response as? HTTPURLResponse,
                      response.statusCode < 200,
                      response.statusCode >= 300 {
                completion(.failure(NetworkError.failureStatus))
            }
        }
        
        task.resume()
        return task
    }
    
    private func parse<T: JSONParsable>(
        data: Data, 
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        do {
            let json = try JSON(data: data)
            let model = try T.from(json)
            completion(.success(model))
        } catch {
            completion(.failure(error))
        }
    }
}
