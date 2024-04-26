//
//  ChatContract.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IChatPresenter {
    func onViewReady()
    func onFollowChat()
    func onLongPress()
}

protocol IChatView: AnyObject {
    func setFollowButton(isHidden: Bool)
    func onNewMessage(_ model: MessageViewModel)
    func didReceiveAction()
}

