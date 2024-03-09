//
//  MainFlowCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

final class MainFlowCoordinator: BaseCoordinator {
    
    private let connectModuleAssembly: IConnectModuleAssembly
    private let startModuleAssembly: IStartStreamModuleAssembly
    private let faceTrackingModuleAssembly: IFaceTrackingModuleAssembly
    private let debugMenuModuleAssembly: IDebugMenuModuleAssembly
    private let router: IRouter
    
    var coordinatorCompletion: CompletionBlock?
    
    init(
        connectModuleAssembly: IConnectModuleAssembly,
        startModuleAssembly: IStartStreamModuleAssembly,
        faceTrackingModuleAssembly: IFaceTrackingModuleAssembly,
        debugMenuModuleAssembly: IDebugMenuModuleAssembly,
        router: IRouter
    ) {
        self.router = router
        self.connectModuleAssembly = connectModuleAssembly
        self.startModuleAssembly = startModuleAssembly
        self.faceTrackingModuleAssembly = faceTrackingModuleAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
    }
    
    override func startFlow() {
        let module = connectModuleAssembly.assemble(for: self)
        router.setRootModule(module, hideBar: false)
    }
    
    override func onNext(_ action: CoordinatorAction) {
        switch action {
        case .startModuleOnFaceTapped:
            let module = faceTrackingModuleAssembly.assemble(for: self)
            router.push(module, animated: true)
        case .startModuleOnBodyTapped:
            break
        case .onLongPress:
            let module = debugMenuModuleAssembly.assemble(for: self)
            router.present(module, animated: true)
        case .connectModuleSuccess:
            let module = startModuleAssembly.assemble(for: self)
            router.push(module, animated: true)
        case .connectModuleOnLogout:
            onFinish?()
        default:
            break
        }
    }
}
