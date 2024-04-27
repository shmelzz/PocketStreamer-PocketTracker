//
//  SelectPlatformModuleAssembly.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol ISelectPlatformModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}

final class SelectPlatformModuleAssembly: BaseModuleAssembly, ISelectPlatformModuleAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModule {
        let view = SelectPlatformViewController()
        let presenter = SelectPlatformPresenter(
            view: view,
            platformManager: servicesAssembly.platformManager,
            channelService: servicesAssembly.channelService,
            platformChannelStorage: servicesAssembly.platformChannelStorage,
            coordinator: coordinator
        )
        view.presenter = presenter
        return Module(viewToPresent: view, viewOutput: presenter)
    }
}
