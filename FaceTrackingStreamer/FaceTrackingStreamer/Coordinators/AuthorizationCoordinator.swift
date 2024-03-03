//
//  AuthorizationCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

final class AuthorizationCoordinator: BaseCoordinator {
    
    private let router: IRouter
    private let authModuleAssembly: IAuthModuleAssembly
    private let debugMenuModuleAssembly: IDebugMenuModuleAssembly
    
    init(
        router: IRouter,
        authModuleAssembly: IAuthModuleAssembly,
        debugMenuModuleAssembly: IDebugMenuModuleAssembly
    ) {
        self.router = router
        self.authModuleAssembly = authModuleAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
    }
    
    override func startFlow() {
        let module = authModuleAssembly.assemble(for: self)
        router.setRootModule(module, hideBar: true)
    }
    
    override func onNext(_ action: CoordinatorAction) {
        switch action {
        case .loginDidSuccessed:
            onFinish?()
        case .onLongPress:
            let module = debugMenuModuleAssembly.assemble(for: self)
            router.present(module, animated: true)
        default:
            break
        }
    }
}
