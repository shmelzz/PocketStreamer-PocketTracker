//
//  ChatContract.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IChatPresenter {
    func onFollowChat()
    func onLongPress()
}

protocol IChatView: AnyObject {
    func onNewMessage(_ model: MessageModel)
}

