//
//  ModulesAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol IModulesAssembly {
    var authModuleAssembly: IAuthModuleAssembly { get }
    
    var startModuleAssembly: IStartStreamModuleAssembly { get }
}

final class ModulesAssembly: IModulesAssembly {
    
    private let servicesAssembly: IServicesAssembly
    
    init(servicesAssembly: IServicesAssembly) {
        self.servicesAssembly = servicesAssembly
    }
    
    lazy var authModuleAssembly: IAuthModuleAssembly = {
        AuthModuleAssembly(servicesAssembly: servicesAssembly)
    }()
    
    lazy var startModuleAssembly: IStartStreamModuleAssembly = {
        StartStreamModuleAssembly(servicesAssembly: servicesAssembly)
    }()
}
