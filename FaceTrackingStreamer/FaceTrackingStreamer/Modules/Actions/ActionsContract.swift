//
//  ActionsContract.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IActionsPresenter {
    func onActionTapped(_ actionModel: ActionRequestModel)
    func onLongPress()
}

protocol IActionsView: AnyObject {
    
}
