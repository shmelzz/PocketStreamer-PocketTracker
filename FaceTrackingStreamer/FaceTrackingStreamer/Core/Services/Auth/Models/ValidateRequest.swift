//
//  ValidateRequest.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

struct ValidateResponse: Decodable, JSONParsable {
    let username: String
}

final class ValidateRequest: CoreRequest, IJSONRequest {
    
    typealias ResponseModel = ValidateResponse
    
    override func type() -> RequestType {
        .POST
    }
    
    override func path() -> String {
        "/auth/validate"
    }
    
    override func authorizationType() -> AuthorizationType {
        .token
    }
}
