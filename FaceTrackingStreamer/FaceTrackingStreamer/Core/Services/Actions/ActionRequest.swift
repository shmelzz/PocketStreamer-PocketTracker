//
//  ActionRequest.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

struct ActionModel: Encodable {
    let payload: String
    let type: String
}

final class ActionRequest: CoreRequest, IJSONRequest {
    
    let payload: String
    let actionType: String
    let sessionId: String
    
    init(
        payload: String,
        type: String,
        sessionId: String,
        endpoint: String
    ) {
        self.payload = type
        self.actionType = type
        self.sessionId = sessionId
        super.init(endpoint: endpoint)
    }
    
    typealias ResponseModel = EmptyResponse
    
    override func type() -> RequestType {
        .POST
    }
    
    override func path() -> String {
        "/action/pocketaction"
    }
    
    override func httpHeaderFields() -> [String : String] {
        var headers = super.httpHeaderFields()
        headers["SessionId"] = sessionId
        return headers
    }
    
    override func httpBodyData() -> Data? {
        let model = ActionModel(payload: payload, type: actionType)
        let data = try? JSONEncoder().encode(model)
        return data
    }
    
    override func authorizationType() -> AuthorizationType {
        .token
    }
}
