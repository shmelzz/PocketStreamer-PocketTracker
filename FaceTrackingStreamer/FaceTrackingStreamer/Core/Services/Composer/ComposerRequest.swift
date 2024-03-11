//
//  ComposerRequest.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

struct ComposerRequestModel: Encodable {
    let sessionid: String
}

struct EmptyResponse: Decodable, JSONParsable {
    
}

final class ComposerRequest: CoreRequest, IJSONRequest {
    
    let sessionId: String
    
    init(
        sessionId: String,
        endpoint: String
    ) {
        self.sessionId = sessionId
        super.init(endpoint: endpoint)
    }
    
    typealias ResponseModel = EmptyResponse
    
    override func type() -> RequestType {
        .POST
    }
    
    override func path() -> String {
        "/auth/findcomposer"
    }
    
    override func httpBodyData() -> Data? {
        let model = ComposerRequestModel(sessionid: sessionId)
        let data = try? JSONEncoder().encode(model)
        return data
    }
    
    override func authorizationType() -> AuthorizationType {
        .token
    }
}

