//
//  FaceTrackingModuleAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 03.03.2024.
//

import Foundation

protocol IFaceTrackingModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class FaceTrackingModuleAssembly: BaseModuleAssembly, IFaceTrackingModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let oldView = OldFaceTrackingViewController(
            endpointStorage: servicesAssembly.endpointStorage,
            authStorage: servicesAssembly.sessionStorage,
            sessionProvider: servicesAssembly.sessionProvider,
            actionsService: servicesAssembly.actionsService,
            chatService: servicesAssembly.chatService,
            platformManager: servicesAssembly.platformManager,
            endpointProvider: servicesAssembly.endpointProvider,
            actionsStorage: servicesAssembly.actionsStorage,
            coordinator: coordinator
        )
        
        let actionsAssembly = ActionsModuleViewAssembly(servicesAssembly: servicesAssembly)
        let moduleView = actionsAssembly.assemble(for: coordinator)
        
        let chatAssembly = ChatModuleViewAssembly(servicesAssembly: servicesAssembly)
        let chatModuleView = chatAssembly.assemble(for: coordinator)
        
        
        let view = FaceTrackingViewController(
            actionsListView: moduleView.viewToPresent,
            chatView: chatModuleView.viewToPresent
        )
        
        let presenter = FaceTrackingPresenter(
            endpointStorage: servicesAssembly.endpointStorage,
            endpointProvider: servicesAssembly.endpointProvider,
            authStorage: servicesAssembly.sessionStorage,
            sessionProvider: servicesAssembly.sessionProvider,
            actionsService: servicesAssembly.actionsService,
            chatService: servicesAssembly.chatService,
            platformManager: servicesAssembly.platformManager,
            faceTrackingService: servicesAssembly.faceTrackingService,
            view: oldView,
            coordinator: coordinator
        )
        
        view.presenter = presenter
        return Module(viewToPresent: oldView, viewOutput: presenter)
    }
}
