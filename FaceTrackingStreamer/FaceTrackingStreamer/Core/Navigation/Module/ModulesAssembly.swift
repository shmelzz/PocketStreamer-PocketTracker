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
    
    var faceTrackingModuleAssembly: IFaceTrackingModuleAssembly { get }
    
    var bodyTrackingModuleAssembly: IBodyTrackingModuleAssembly { get }
    
    var debugMenuModuleAssembly: IDebugMenuModuleAssembly { get }
    
    var connectModuleAssembly: IConnectModuleAssembly { get }
    
    var selectPlatformModuleAssembly: ISelectPlatformModuleAssembly { get }
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
    
    lazy var faceTrackingModuleAssembly: IFaceTrackingModuleAssembly = {
        FaceTrackingModuleAssembly(servicesAssembly: servicesAssembly)
    }()
    
    lazy var bodyTrackingModuleAssembly: IBodyTrackingModuleAssembly = {
        BodyTrackingModuleAssembly(servicesAssembly: servicesAssembly)
    }()
    
    lazy var debugMenuModuleAssembly: IDebugMenuModuleAssembly = {
        DebugMenuModuleAssembly(servicesAssembly: servicesAssembly)
    }()
    
    lazy var connectModuleAssembly: IConnectModuleAssembly = {
        ConnectModuleAssembly(servicesAssembly: servicesAssembly)
    }()
    
    lazy var selectPlatformModuleAssembly: ISelectPlatformModuleAssembly = {
        SelectPlatformModuleAssembly(servicesAssembly: servicesAssembly)
    }()
}
