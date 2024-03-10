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
    private let findComposerService: IFindComposerService
    
    init(
        view: IConnectView,
        sessionProvider: ISessionProvider,
        findComposerService: IFindComposerService,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.sessionProvider = sessionProvider
        self.findComposerService = findComposerService
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
        findComposerService.find { [weak self] result in
            switch result {
            case .success:
                self?.finish(.connectModuleSuccess)
            case .failure(let data):
                self?.finish(.connectModuleFailure(text: data.localizedDescription))
            }
        }
    }
    
    func onLogoutTapped() {
        sessionProvider.reset()
        finish(.connectModuleOnLogout)
    }
}
