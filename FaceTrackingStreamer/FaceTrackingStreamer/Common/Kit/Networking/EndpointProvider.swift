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
    
    private enum Ports {
        static let http = 8088
        static let faceTracking = 4545
    }
    
    private let apiEndpointStorage: IApiEndpointStorage
    
    init(apiEndpointStorage: IApiEndpointStorage) {
        self.apiEndpointStorage = apiEndpointStorage
    }
    
    func httpEndpoint() -> String {
        let data = apiEndpointStorage.get()
        let currentEnv = data?.environments.first(where: {$0.isSelected})
        let host = currentEnv?.endpoint.endpoint ?? "84.201.133.103"
        
        return "\(host):\(Ports.http)"
    }
}
