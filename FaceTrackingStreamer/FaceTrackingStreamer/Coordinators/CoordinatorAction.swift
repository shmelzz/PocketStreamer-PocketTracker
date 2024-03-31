//
//  CoordinatorActions.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

enum CoordinatorAction {
    case loginDidSuccessed
    case loginError
    case registerError
    case registerSuccess
    
    case connectModuleSuccess
    case connectModuleFailure(text: String?)
    case connectModuleOnLogout
    
    case selectPlatformContinue(isLiveChannel: Bool)
    case selectPlatformValidationError
    
    case startModuleOnFaceTapped
    case startModuleOnBodyTapped
    
    case onLongPress
}
