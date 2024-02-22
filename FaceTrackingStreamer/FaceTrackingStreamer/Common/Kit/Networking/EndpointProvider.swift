//
//  EndpointProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 20.02.2024.
//

import Foundation

protocol IEndpointProvider {
    func httpEndpoint() -> String
}

final class EndpointProvider: IEndpointProvider {
    
    func httpEndpoint() -> String {
        return "84.201.133.103:8088"
    }
}
