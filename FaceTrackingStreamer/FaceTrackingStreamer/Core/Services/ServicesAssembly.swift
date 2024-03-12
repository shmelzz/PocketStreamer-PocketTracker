//
//  ServicesAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IServicesAssembly: AnyObject {
    
    var authService: IAuthService { get }
    
    var endpointStorage: IApiEndpointStorage { get }
    
    var sessionStorage: ISessionStorage { get }
    
    var sessionProvider: ISessionProvider { get }
    
    var findComposerService: IFindComposerService { get }
    
    var actionsService: IActionsService { get }
    
    var chatService: IChatService { get }
    
    var platformManager: IPlatformManager { get }
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
    
    lazy var endpointStorage: IApiEndpointStorage = {
        ApiEndpointStorage(suiteName: "PocketTracker")
    }()
    
    lazy var sessionStorage: ISessionStorage = {
        SessionStorage(suiteName: "PocketTracker")
    }()
    
    lazy var sessionProvider: ISessionProvider = {
        SessionProvider(sessionStorage: sessionStorage)
    }()
    
    lazy var findComposerService: IFindComposerService = {
        FindComposerService(
            requestManager: requestManager,
            endpointProvider: endpointProvider,
            sessionProvider: sessionProvider
        )
    }()
    
    lazy var actionsService: IActionsService = {
        ActionsService(
            requestManager: requestManager,
            endpointProvider: endpointProvider,
            sessionProvider: sessionProvider
        )
    }()
    
    lazy var chatService: IChatService = {
        ChatService(
            endpointProvider: endpointProvider,
            requestBuilder: RequestBuilder(sessionProvider: sessionProvider),
            sessionProvider: sessionProvider
        )
    }()
    
    lazy var platformManager: IPlatformManager  = {
        PlatformManager()
    }()
}
