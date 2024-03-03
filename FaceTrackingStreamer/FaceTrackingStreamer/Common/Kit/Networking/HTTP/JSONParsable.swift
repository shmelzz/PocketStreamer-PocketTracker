import Foundation
import SwiftyJSON

protocol JSONParsable {
    static func from(_ json: JSON) throws -> Self
}

extension JSONParsable where Self: Decodable {
    static func from(_ json: JSON) throws -> Self {
        try JSONDecoder().decode(Self.self, from: json.rawData())
    }
}
