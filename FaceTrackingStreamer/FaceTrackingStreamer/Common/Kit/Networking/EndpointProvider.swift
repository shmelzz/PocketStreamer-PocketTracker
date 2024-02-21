//
//  EndpointProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 20.02.2024.
//

import Foundation

protocol IEndpointProvider {
    func endpoint() -> String
}

final class EndpointProvider: IEndpointProvider {
    func endpoint() -> String {
        return "84.201.133.103:8088"
    }
}
