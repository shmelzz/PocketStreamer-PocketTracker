//
//  BodyTrackingPresenter.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 09.03.2024.
//

import Foundation

final class BodyTrackingPresenter: BaseModuleOutput, IBodyTrackingPresenter {
    
    private weak var view: IBodyTrackingView?
    
    init(
        view: IBodyTrackingView,
        coordinator: ICoordinator
    ) {
        self.view = view
        super.init(coordinator: coordinator)
    }
    
    func onViewDidLoad() {
        
    }
}
