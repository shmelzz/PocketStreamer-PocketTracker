//
//  CoordinatorFactory.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

typealias CompletionBlock = () -> Void

protocol ICoordinatorFactory: AnyObject {
    func makeAuthorizationCoordinator(router: any IRouter) -> Coordinatable & AuthorizationCoordinatorOutput
    func makeMainCoordinator(router: any IRouter) -> Coordinatable & MainCoordinatorOutput
}

protocol MainCoordinatorOutput: AnyObject {
    var finishFlow: CompletionBlock? { get set }
}

protocol AuthorizationCoordinatorOutput: AnyObject {
    var finishFlow: CompletionBlock? { get set }
}

final class CoordinatorFactory: ICoordinatorFactory {

    func makeAuthorizationCoordinator(router: any IRouter) -> AuthorizationCoordinatorOutput & Coordinatable {
        return AuthorizationCoordinator()
    }
    
    func makeMainCoordinator(router: any IRouter) -> Coordinatable & MainCoordinatorOutput {
        return MainFlowCoordinator()
    }
}
