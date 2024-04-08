//
//  IModuleOutput.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IModuleOutput: AnyObject {
    func finish(_ action: CoordinatorAction)
}

class BaseModuleOutput: NSObject, IModuleOutput {
    
    private let coordinator: ICoordinator
    
    init(coordinator: ICoordinator) {
        self.coordinator = coordinator
    }
    
    func finish(_ action: CoordinatorAction) {
        DispatchQueue.main.async { [weak self] in
            self?.coordinator.onNext(action)
        }
    }
}
