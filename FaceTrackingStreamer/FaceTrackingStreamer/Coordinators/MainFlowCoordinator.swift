//
//  MainFlowCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

final class MainFlowCoordinator: BaseCoordinator {
    
    private let startModuleAssembly: IStartStreamModuleAssembly
    private let router: IRouter
    
    var coordinatorCompletion: CompletionBlock?
    
    init(
        startModuleAssembly: IStartStreamModuleAssembly,
        router: IRouter
    ) {
        self.router = router
        self.startModuleAssembly = startModuleAssembly
    }
    
    override func startFlow() {
        let module = startModuleAssembly.assemble(for: self)
        router.setRootModule(module, hideBar: true)
    }
}
