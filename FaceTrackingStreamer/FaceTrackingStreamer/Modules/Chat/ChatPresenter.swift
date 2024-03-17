//
//  ChatPresenter.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

final class ChatPresenter: BaseModuleOutput, IChatPresenter, IChatServiceDelegate {

    private weak var view: IChatView?
    
    private let chatService: IChatService
    private let platformManager: IPlatformManager
    
    init(
        chatService: IChatService,
        platformManager: IPlatformManager,
        view: IChatView,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.chatService = chatService
        self.platformManager = platformManager
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IChatServiceDelegate
    
    func didReceive(new message: MessageModel) {
        view?.onNewMessage(message)
    }
    
    // MARK: - IChatPresenter
    
    func onFollowChat() {
        let platformName = platformManager.getSelectedPlatform()
        chatService.connect(model: StreamModel(platform: "twitch", channel: platformName ?? ""))
    }
    
    func onViewReady() {
        view?.setFollowButton(isHidden: platformManager.getSelectedPlatform() == nil)
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
