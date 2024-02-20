//
//  CoreRequest.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 20.02.2024.
//

import Foundation

class CoreRequest: IRequest {
    
    private let endpoint: String
    
    init(endpoint: String) {
        self.endpoint = endpoint
    }
    
    func type() -> RequestType {
        .GET
    }
    
    func domain() -> String {
        endpoint
    }
    
    func path() -> String {
        ""
    }
    
    func httpBodyData() -> Data? {
        nil
    }
    
    func parametres() -> [String : String] {
        [:]
    }
    
    func httpHeaderFields() -> [String : String] {
        [
            "Content-Type": "application/json",
            "Accept": "application/json"
        
        ]
    }
    
    func authorizationType() -> AuthorizationType {
        .token
    }
}
