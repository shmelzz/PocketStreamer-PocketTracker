//
//  StartStreamPresenter.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 22.02.2024.
//

import Foundation

final class StartStreamPresenter: BaseModuleOutput, IStartStreamPresenter {
    
    private let view: IStartStreamView
    
    init(
        view: IStartStreamView,
        coordinator: ICoordinator
    ) {
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IStartStreamPresenter
    
    func onFaceTapped() {
        
    }
    
    func onBodyTapped() {
        
    }
}
