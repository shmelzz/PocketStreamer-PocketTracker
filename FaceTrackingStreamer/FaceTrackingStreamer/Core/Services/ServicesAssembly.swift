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
    
    var endpointProvider: IEndpointProvider { get }
    
    var channelService: IChannelService { get }
    
    var faceTrackingService: IFaceTrackingService { get }
    
    var actionsStorage: IActionsStorage { get }
    
    var platformChannelStorage: IPlatformChannelStorage { get }
}

final class ServicesAssembly: IServicesAssembly {
    
    private enum Constants {
        static let suiteName = "PocketTracker"
    }
    
    private let requestManager: IRequestManager
    private let _endpointProvider: IEndpointProvider
    
    init(requestManager: IRequestManager, endpointProvider: IEndpointProvider) {
        self.requestManager = requestManager
        self._endpointProvider = endpointProvider
    }
    
    lazy var authService: IAuthService = {
        AuthService(
            requestManager: requestManager,
            endpointProvider: endpointProvider
        )
    }()
    
    lazy var endpointStorage: IApiEndpointStorage = {
        ApiEndpointStorage(suiteName: Constants.suiteName)
    }()
    
    lazy var sessionStorage: ISessionStorage = {
        SessionStorage(suiteName: Constants.suiteName)
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
    
    lazy var endpointProvider: IEndpointProvider = {
        _endpointProvider
    }()
    
    lazy var channelService: IChannelService = {
        ChannelService(
            requestManager: requestManager,
            endpointProvider: endpointProvider,
            sessionProvider: sessionProvider
        )
    }()
    
    lazy var faceTrackingService: IFaceTrackingService = {
        FaceTrackingService(
            endpointProvider: endpointProvider,
            sessionProvider: sessionProvider
        )
    }()
    
    lazy var actionsStorage: IActionsStorage = {
        ActionsStorage()
    }()
    
    lazy var platformChannelStorage: IPlatformChannelStorage = {
        PlatformChannelStorage(suiteName: Constants.suiteName)
    }()
}
