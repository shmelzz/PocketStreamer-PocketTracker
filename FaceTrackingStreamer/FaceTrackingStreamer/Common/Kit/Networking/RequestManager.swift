import Foundation
import SwiftyJSON

protocol IResponse: Decodable {}

enum NetworkError: Error {
    case failureStatus(_ message: ErrorMessage?)
}

struct ErrorMessage: Decodable, Error {
    let error: String?
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
            urlRequest = try requestBuilder.buildHTTP(request: request)
            print(urlRequest)
        } catch {
            completion(.failure(error))
            return DefaultCancelable()
        }
        
        return execute(urlRequest: urlRequest) { [weak self] result in
            switch result {
            case let .success(data):
                print(data)
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
            if let response = response as? HTTPURLResponse,
               response.statusCode < 200 || response.statusCode >= 300 {
                let message = try? JSONDecoder().decode(ErrorMessage.self, from: data ?? Data())
                completion(.failure(NetworkError.failureStatus(message)))
            } else if let data = data {
                completion(.success(data))
            } else if let error = error {
                completion(.failure(error))
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
            print(json)
            let model = try T.from(json)
            completion(.success(model))
        } catch {
            completion(.failure(error))
        }
    }
}
