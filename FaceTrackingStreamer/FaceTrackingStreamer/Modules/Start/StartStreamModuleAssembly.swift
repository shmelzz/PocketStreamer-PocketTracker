//
//  StartModuleAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IStartStreamModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class StartStreamModuleAssembly: BaseModuleAssembly, IStartStreamModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = StartStreamViewController()
        let presenter = StartStreamPresenter(view: view, coordinator: coordinator)
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
