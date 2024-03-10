//
//  SelectPlatformPresenter.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

final class SelectPlatformPresenter: BaseModuleOutput, ISelectPlatformPresenter {
    
    private weak var view: ISelectPlatformView?
    
    init(
        view: ISelectPlatformView,
        coordinator: ICoordinator
    ) {
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    func onContinueTapped() {
        
    }
    
    func onLongPress() {
        
    }
}
