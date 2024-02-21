//
//  ServicesAssembly.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation


protocol IServicesAssembly: AnyObject {
    var authService: IAuthService { get }
}

//final class ServicesAssembly: IServicesAssembly {
//    
//}
