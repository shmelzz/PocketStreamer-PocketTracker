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
        let view = OldFaceTrackingViewController(
            endpointStorage: servicesAssembly.endpointStorage,
            authStorage: servicesAssembly.sessionStorage,
            sessionProvider: servicesAssembly.sessionProvider,
            actionsService: servicesAssembly.actionsService,
            chatService: servicesAssembly.chatService,
            platformManager: servicesAssembly.platformManager,
            endpointProvider: servicesAssembly.endpointProvider,
            coordinator: coordinator
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
            view: view,
            coordinator: coordinator
        )
        // view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
