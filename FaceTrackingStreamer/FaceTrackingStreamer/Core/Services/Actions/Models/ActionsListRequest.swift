//
//  ActionsListRequest.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 17.03.2024.
//

import Foundation

struct ActionModel: Decodable {
    let displayName: String
    let payload: String
    let type: String
}

struct ActionsList: Decodable, JSONParsable {
    let actions: [ActionModel]
}

final class ActionsListRequest: CoreRequest, IJSONRequest {

    let sessionId: String
    
    init(
        sessionId: String,
        endpoint: String
    ) {
        self.sessionId = sessionId
        super.init(endpoint: endpoint)
    }
    
    typealias ResponseModel = ActionsList
    
    override func type() -> RequestType {
        .GET
    }
    
    override func path() -> String {
        "/action/document"
    }
    
    override func httpHeaderFields() -> [String : String] {
        var headers = super.httpHeaderFields()
        headers["SessionId"] = sessionId
        return headers
    }
    
    override func authorizationType() -> AuthorizationType {
        .token
    }
}
