//
//  IRouter.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IRouter {
    
    func present(_ module: any IModule)
    func present(_ module: any IModule, animated: Bool)
    
    func push(_ module: any IModule)
    func push(_ module: any IModule, animated: Bool)
    func push(_ module: any IModule, animated: Bool, completion: CompletionBlock?)
    
    func popModule()
    func popModule(animated: Bool)
    
    func dismissModule()
    func dismissModule(animated: Bool, completion: CompletionBlock?)
    
    func setRootModule(_ module: any IModule)
    func setRootModule(_ module: any IModule, hideBar: Bool)
    
    func popToRootModule(animated: Bool)
    
    func presentOKAlert(with text: String)
    func presentRetryAlert(with text: String, nextModule: any IModule)
}
