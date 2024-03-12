//
//  CoordinatorActions.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

enum CoordinatorAction {
    case loginDidSuccessed
    
    case connectModuleSuccess
    case connectModuleFailure(text: String?)
    case connectModuleOnLogout
    
    case selectPlatformContinue
    
    case startModuleOnFaceTapped
    case startModuleOnBodyTapped
    
    case onLongPress
}
