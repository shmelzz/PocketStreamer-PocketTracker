//
//  ActionsContract.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IActionsPresenter {
    func onViewReady()
    func onActionTapped(_ actionModel: ActionRequestModel)
    func onActionTapped(with index: Int)
    func onLongPress()
}

protocol IActionsView: AnyObject {
    func setActionsView(with models: [ActionModel])
    
}
