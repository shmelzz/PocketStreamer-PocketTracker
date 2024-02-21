//
//  ServicesAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IServicesAssembly: AnyObject {
    var authService: IAuthService { get }
}

final class ServicesAssembly: IServicesAssembly {
    
    private let requestManager: IRequestManager
    private let endpointProvider: IEndpointProvider
    
    init(requestManager: IRequestManager, endpointProvider: IEndpointProvider) {
        self.requestManager = requestManager
        self.endpointProvider = endpointProvider
    }
    
    lazy var authService: IAuthService = {
        AuthService(
            requestManager: requestManager,
            endpointProvider: endpointProvider
        )
    }()
}
