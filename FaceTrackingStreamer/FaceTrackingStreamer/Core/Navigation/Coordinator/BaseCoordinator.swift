//
//  BaseCoordinator.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol ICoordinator: AnyObject {
    var onFinish: CompletionBlock? { get set }
    
    func startFlow()
    func addDependency(_ coordinator: ICoordinator)
    func removeDependency(_ coordinator: ICoordinator?)
    func onNext(_ action: CoordinatorAction)
}

class BaseCoordinator: ICoordinator {
    
    var onFinish: CompletionBlock?
    
    private var childCoordinators: [ICoordinator] = []
    
    // Add only unique object
    func addDependency(_ coordinator: ICoordinator) {
        for element in childCoordinators {
            if element === coordinator { return }
        }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: ICoordinator?) {
        guard childCoordinators.isEmpty == false,
              let coordinator = coordinator else { return }
        
        for (index, element) in childCoordinators.enumerated() {
            if element === coordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
    func onNext(_ action: CoordinatorAction) { }
    
    func startFlow() {}
}
