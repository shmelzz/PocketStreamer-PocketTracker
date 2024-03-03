//
//  BodyTrackingModuleAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 03.03.2024.
//

import Foundation

protocol IBodyTrackingModuleAssembly {
    func assemble(for coordinator: ICoordinator) -> any IModule
}


