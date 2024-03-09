//
//  ConnectModuleAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 09.03.2024.
//

import Foundation

protocol IConnectModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class ConnectModuleAssembly: BaseModuleAssembly, IConnectModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = ConnectViewController()
        let presenter = ConnectPresenter(
            view: view,
            sessionProvider: servicesAssembly.sessionProvider,
            coordinator: coordinator
        )
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
