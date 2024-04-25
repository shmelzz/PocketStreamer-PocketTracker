//
//  BodyTrackingModuleAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 03.03.2024.
//

import Foundation

protocol IBodyTrackingModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class BodyTrackingModuleAssembly: BaseModuleAssembly, IBodyTrackingModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = BodyTrackingViewController(
            servicesAssembly: servicesAssembly
        )
        
        let presenter = BodyTrackingPresenter(
            view: view,
            coordinator: coordinator
        )
        
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
