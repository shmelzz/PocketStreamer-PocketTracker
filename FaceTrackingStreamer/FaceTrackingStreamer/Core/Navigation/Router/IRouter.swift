//
//  IRouter.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IRouter: IModule {
    
    func present(_ module: IModule?)
    func present(_ module: IModule?, animated: Bool)
    
    func push(_ module: IModule?)
    func push(_ module: IModule?, animated: Bool)
    func push(_ module: IModule?, animated: Bool, completion: CompletionBlock?)
    
    func popModule()
    func popModule(animated: Bool)
    
    func dismissModule()
    func dismissModule(animated: Bool, completion: CompletionBlock?)
    
    func setRootModule(_ module: IModule?)
    func setRootModule(_ module: IModule?, hideBar: Bool)
    
    func popToRootModule(animated: Bool)
}
