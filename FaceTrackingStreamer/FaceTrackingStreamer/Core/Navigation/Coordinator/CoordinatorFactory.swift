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
            authModuleAssembly: modulesAssembly.authModuleAssembly,
            debugMenuModuleAssembly: modulesAssembly.debugMenuModuleAssembly
        )
    }
    
    func buildMainFlowCoordinator(router: any IRouter) -> ICoordinator {
        return MainFlowCoordinator(
            connectModuleAssembly: modulesAssembly.connectModuleAssembly,
            startModuleAssembly: modulesAssembly.startModuleAssembly,
            faceTrackingModuleAssembly: modulesAssembly.faceTrackingModuleAssembly,
            debugMenuModuleAssembly: modulesAssembly.debugMenuModuleAssembly,
            selectPlatformModuleAssembly: modulesAssembly.selectPlatformModuleAssembly,
            router: router
        )
    }
}

