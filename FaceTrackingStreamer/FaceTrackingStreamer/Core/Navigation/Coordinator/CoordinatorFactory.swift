//
//  CoordinatorFactory.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

typealias CompletionBlock = () -> Void

protocol ICoordinatorFactory: AnyObject {
    func buildAuthorizationCoordinator(router: any IRouter) -> ICoordinator
    func buildMainFlowCoordinator(router: any IRouter) -> ICoordinator
}

final class CoordinatorFactory: ICoordinatorFactory {
    
    private let modulesAssembly: IModulesAssembly
    
    init(modulesAssembly: IModulesAssembly) {
        self.modulesAssembly = modulesAssembly
    }
    
    // MARK: - ICoordinatorFactory
    
    func buildAuthorizationCoordinator(router: any IRouter) -> ICoordinator {
        return AuthorizationCoordinator(
            router: router,
            authModuleAssembly: modulesAssembly.authModuleAssembly
        )
    }
    
    func buildMainFlowCoordinator(router: any IRouter) -> ICoordinator {
        return MainFlowCoordinator(
            startModuleAssembly: modulesAssembly.startModuleAssembly,
            router: router
        )
    }
}

