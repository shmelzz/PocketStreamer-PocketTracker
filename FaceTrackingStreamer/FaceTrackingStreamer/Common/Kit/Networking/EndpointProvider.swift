//
//  EndpointProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 20.02.2024.
//

import Foundation

protocol IEndpointProvider {
    func domains() -> [EnvironmentType: String]
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
    
    private enum Hosts {
        static let prod = "center.pocket-streamer.top"
        static let test = "test-pocketcenter.tedv2023zxcv.top"
    }
    
    private let apiEndpointStorage: IApiEndpointStorage
    
    init(apiEndpointStorage: IApiEndpointStorage) {
        self.apiEndpointStorage = apiEndpointStorage
    }
    
    // MARK: - IEndpointProvider
    
    func authEndpoint() -> String {
        let host = getSelectedHost()
        return "\(host):\(Ports.authService)"
    }
    
    func actionEndpoint() -> String {
        let host = getSelectedHost()
        return "\(host):\(Ports.actionService)"
    }
    
    func faceTrackingEndpoint() -> String {
        let host = getSelectedHost()
        return "\(host):\(Ports.faceTrackingService)"
    }
    
    func streamingEndpoint() -> String {
        let host = getSelectedHost()
        return "\(host):\(Ports.streamingService)"
    }
    
    func domains() -> [EnvironmentType: String] {
        let data = apiEndpointStorage.get()
        
        let prodDomain = data?.environments.first(where: { $0.environment == .prod })
        let testDomain = data?.environments.first(where: { $0.environment == .test })
        
        var prod = Hosts.prod
        if let host = prodDomain?.endpoint.endpoint,
           !host.isEmpty {
            prod = host
        }
        
        var test = Hosts.test
        if let host = testDomain?.endpoint.endpoint,
           !host.isEmpty {
            test = host
        }
        
        return [
            .prod: prod,
            .test: test
        ]
    }
    
    private func getSelectedHost() -> String {
        let data = apiEndpointStorage.get()
        let currentEnv = data?.environments.first(where: {$0.isSelected})
        
        if let host = currentEnv?.endpoint.endpoint,
           !host.isEmpty {
            return host
        }
        
        switch currentEnv?.environment {
        case .prod:
            return Hosts.prod
        case .test, nil:
            return Hosts.test
        }
    }
}
