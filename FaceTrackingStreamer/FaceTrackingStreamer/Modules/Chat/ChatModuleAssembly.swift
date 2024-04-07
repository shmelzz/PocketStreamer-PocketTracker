//
//  ChatModuleAssembly.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IChatModuleViewAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModuleView
}

final class ChatModuleViewAssembly: BaseModuleAssembly, IChatModuleViewAssembly {
    
    func assemble(for coordinator: ICoordinator) -> any IModuleView {
        let view = ChatView()
        let presenter = ChatPresenter(
            chatService: servicesAssembly.chatService,
            platformManager: servicesAssembly.platformManager,
            view: view,
            coordinator: coordinator
        )
        
        servicesAssembly.chatService.setDelegate(presenter)
        
        view.presenter = presenter
        return ModuleView(viewToPresent: view, viewOutput: presenter)
    }
}
