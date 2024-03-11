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
    
    init(
        chatService: IChatService,
        view: IChatView,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.chatService = chatService
        super.init(coordinator: coordinator)
    }
    
    // MARK: - IChatServiceDelegate
    
    func didReceive(new message: MessageModel) {
        view?.onNewMessage(message)
    }
    
    // MARK: - IChatPresenter
    
    func onFollowChat() {
        chatService.connect(model: StreamModel(platform: "twitch", channel: ""))
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
