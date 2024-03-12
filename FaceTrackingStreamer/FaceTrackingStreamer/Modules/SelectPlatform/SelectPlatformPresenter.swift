//
//  SelectPlatformPresenter.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

final class SelectPlatformPresenter: BaseModuleOutput, ISelectPlatformPresenter {
    
    private weak var view: ISelectPlatformView?
    
    private let platformManager: IPlatformManager
    
    init(
        view: ISelectPlatformView,
        platformManager: IPlatformManager,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.platformManager = platformManager
        super.init(coordinator: coordinator)
    }
    
    func onContinueTapped(platform name: String?) {
        platformManager.selectPlatform(name)
        finish(.selectPlatformContinue)
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
