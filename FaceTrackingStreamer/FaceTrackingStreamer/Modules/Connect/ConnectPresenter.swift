//
//  ConnectPresenter.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 09.03.2024.
//

import Foundation

final class ConnectPresenter: BaseModuleOutput, IConnectPresenter {
    
    private weak var view: IConnectView?
    
    private let sessionProvider: ISessionProvider
    
    init(
        view: IConnectView,
        sessionProvider: ISessionProvider,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.sessionProvider = sessionProvider
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IStartStreamPresenter
    
    func onConnectTapped() {
//        finish(.startModuleOnFaceTapped)
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
    
    func onConnectSuccess(with result: String) {
        sessionProvider.sessionId = result
        finish(.connectModuleSuccess)
    }
}
