//
//  IWebSocketRequest.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 22.02.2024.
//

import Foundation

protocol IWebSocketRequest {
    
    func domain() -> String
    
    func path() -> String
    
    func authorizationType() -> AuthorizationType
    
    func headerFields() -> [String:String]
}
