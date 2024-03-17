//
//  ChannelValidationRequest.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh
//

import Foundation

struct ChannelModel: Encodable {
    let channel: String
}

struct ChannelValidationModel: Decodable, JSONParsable {
    let isLive: Bool
    
    enum CodingKeys: String, CodingKey {
        case isLive = "is_live"
    }
}

final class ChannelValidationRequest: CoreRequest, IJSONRequest {
    
    let channelName: String
    let sessionId: String
    
    init(
        channelName: String,
        sessionId: String,
        endpoint: String
    ) {
        self.channelName = channelName
        self.sessionId = sessionId
        super.init(endpoint: endpoint)
    }
    
    typealias ResponseModel = ChannelValidationModel
    
    override func type() -> RequestType {
        .POST
    }
    
    override func path() -> String {
        "/twitch/channel-validation"
    }
    
    override func httpHeaderFields() -> [String : String] {
        var headers = super.httpHeaderFields()
        headers["SessionId"] = sessionId
        return headers
    }
    
    override func httpBodyData() -> Data? {
        let model = ChannelModel(channel: channelName)
        let data = try? JSONEncoder().encode(model)
        return data
    }
    
    override func authorizationType() -> AuthorizationType {
        .token
    }
}
