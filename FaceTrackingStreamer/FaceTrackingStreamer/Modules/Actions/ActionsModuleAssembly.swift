//
//  ActionsModuleAssembly.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IActionsModuleViewAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModuleView
}

final class ActionsModuleViewAssembly: BaseModuleAssembly, IActionsModuleViewAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModuleView {
        let view = ActionsListView()
        let presenter = ActionsPresenter(
            actionsService: servicesAssembly.actionsService,
            actionsStorage: servicesAssembly.actionsStorage,
            view: view,
            coordinator: coordinator
        )
        
        view.presenter = presenter
        return ModuleView(viewToPresent: view, viewOutput: presenter)
    }
}
