//
//  StartModuleAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IStartModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class StartModuleAssembly: BaseModuleAssembly, IStartModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = StartViewController()
        let presenter = AuthPresenter(authService: servicesAssembly.authService, coordinator: coordinator)
//        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
