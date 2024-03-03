//
//  MainFlowCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

final class MainFlowCoordinator: BaseCoordinator {
    
    private let startModuleAssembly: IStartStreamModuleAssembly
    private let faceTrackingModuleAssembly: IFaceTrackingModuleAssembly
    private let router: IRouter
    
    var coordinatorCompletion: CompletionBlock?
    
    init(
        startModuleAssembly: IStartStreamModuleAssembly,
        faceTrackingModuleAssembly: IFaceTrackingModuleAssembly,
        router: IRouter
    ) {
        self.router = router
        self.startModuleAssembly = startModuleAssembly
        self.faceTrackingModuleAssembly = faceTrackingModuleAssembly
    }
    
    override func startFlow() {
        let module = startModuleAssembly.assemble(for: self)
        router.setRootModule(module, hideBar: true)
    }
    
    override func onNext(_ action: CoordinatorAction) {
        switch action {
        case .startModuleOnFaceTapped:
            let module = faceTrackingModuleAssembly.assemble(for: self)
            router.push(module, animated: true)
        case .startModuleOnBodyTapped:
            break
        default:
            break
        }
    }
}
