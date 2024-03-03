import Foundation
import SwiftyJSON

protocol IJSONRequest: IRequest {
    associatedtype ResponseModel: JSONParsable
}
