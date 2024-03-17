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
    private let selectPlatformModuleAssembly: ISelectPlatformModuleAssembly
    private let router: IRouter
    
    var coordinatorCompletion: CompletionBlock?
    
    init(
        connectModuleAssembly: IConnectModuleAssembly,
        startModuleAssembly: IStartStreamModuleAssembly,
        faceTrackingModuleAssembly: IFaceTrackingModuleAssembly,
        debugMenuModuleAssembly: IDebugMenuModuleAssembly,
        selectPlatformModuleAssembly: ISelectPlatformModuleAssembly,
        router: IRouter
    ) {
        self.router = router
        self.connectModuleAssembly = connectModuleAssembly
        self.startModuleAssembly = startModuleAssembly
        self.faceTrackingModuleAssembly = faceTrackingModuleAssembly
        self.debugMenuModuleAssembly = debugMenuModuleAssembly
        self.selectPlatformModuleAssembly = selectPlatformModuleAssembly
    }
    
    override func startFlow() {
        let module = connectModuleAssembly.assemble(for: self)
        router.setRootModule(module, hideBar: false)
    }
    
    override func onNext(_ action: CoordinatorAction) {
        switch action {
            
        // Start
            
        case .startModuleOnFaceTapped:
            let module = faceTrackingModuleAssembly.assemble(for: self)
            router.push(module, animated: true)
            
        case .startModuleOnBodyTapped:
            break
            
        case .onLongPress:
            let module = debugMenuModuleAssembly.assemble(for: self)
            router.present(module, animated: true)
            
        // Connect
            
        case .connectModuleSuccess:
            let module = selectPlatformModuleAssembly.assemble(for: self)
            router.push(module, animated: true)
            
        case .connectModuleOnLogout:
            onFinish?()
            
        case let .connectModuleFailure(text):
            router.presentOKAlert(with: text ?? "")
            
        // Select
            
        case .selectPlatformContinue(let isLive):
            let module = startModuleAssembly.assemble(for: self)
            router.push(module, animated: true)
            if !isLive {
                router.presentOKAlert(
                    with: "Channel isn't live. Start stream if you want to follow chat"
                )
            }
            
        case .selectPlatformValidationError:
            let module = startModuleAssembly.assemble(for: self)
            router.presentRetryAlert(
                with: "Channel validation error. Continue without channel connection?",
                nextModule: module
            )
            
            
        case .loginDidSuccessed:
            break
        }
    }
}
