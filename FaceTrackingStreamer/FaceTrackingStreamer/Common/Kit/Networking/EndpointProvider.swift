//
//  EndpointProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 20.02.2024.
//

import Foundation

protocol IEndpointProvider {
    func authEndpoint() -> String
    func actionEndpoint() -> String
    func faceTrackingEndpoint() -> String
    func streamingEndpoint() -> String
}

final class EndpointProvider: IEndpointProvider {
    
    private enum Ports {
        static let authService = 8088
        static let faceTrackingService = 4545
        static let actionService = 9091
        static let streamingService = 7070
    }
    
    private let apiEndpointStorage: IApiEndpointStorage
    
    init(apiEndpointStorage: IApiEndpointStorage) {
        self.apiEndpointStorage = apiEndpointStorage
    }
    
    // MARK: - IEndpointProvider
    
    func authEndpoint() -> String {
        let host = getHost()
        return "\(host):\(Ports.authService)"
    }
    
    func actionEndpoint() -> String {
        let host = getHost()
        return "\(host):\(Ports.actionService)"
    }
    
    func faceTrackingEndpoint() -> String {
        let host = getHost()
        return "\(host):\(Ports.faceTrackingService)"
    }
    
    func streamingEndpoint() -> String {
        let host = getHost()
        return "\(host):\(Ports.streamingService)"
    }
    
    private func getHost() -> String {
        let data = apiEndpointStorage.get()
        let currentEnv = data?.environments.first(where: {$0.isSelected})
        let host = currentEnv?.endpoint.endpoint ?? "84.201.133.103"
        return host
    }
}
