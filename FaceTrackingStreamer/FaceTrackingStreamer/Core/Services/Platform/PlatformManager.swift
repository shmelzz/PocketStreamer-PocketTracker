//
//  PlatformManager.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 12.03.2024.
//

import Foundation

protocol IPlatformManager {
    func selectPlatform(_ name: String?)
    func getSelectedPlatform() -> String?
}

final class PlatformManager: IPlatformManager {
    
    private var selectedPlatformName: String?
    
    func selectPlatform(_ name: String?) {
        selectedPlatformName = name
    }
    
    func getSelectedPlatform() -> String? {
        return selectedPlatformName
    }
}
