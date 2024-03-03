//
//  StartStreamPresenter.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 22.02.2024.
//

import Foundation

final class StartStreamPresenter: BaseModuleOutput, IStartStreamPresenter {
    
    private weak var view: IStartStreamView?
    
    init(
        view: IStartStreamView,
        coordinator: ICoordinator
    ) {
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IStartStreamPresenter
    
    func onFaceTapped() {
        finish(.startModuleOnFaceTapped)
    }
    
    func onBodyTapped() {
        finish(.startModuleOnBodyTapped)
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
