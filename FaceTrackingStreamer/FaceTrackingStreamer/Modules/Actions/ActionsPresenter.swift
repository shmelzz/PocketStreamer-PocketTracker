//
//  ActionsPresenter.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

final class ActionsPresenter: BaseModuleOutput, IActionsPresenter {

    private weak var view: IActionsView?
    
    private let actionsService: IActionsService
    
    init(
        actionsService: IActionsService,
        view: IActionsView,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.actionsService = actionsService
        super.init(coordinator: coordinator)
    }
    
    func onActionTapped(_ actionModel: ActionModel) {
        actionsService.send(action: actionModel) { [weak self] result in
            switch result {
            case .success(let success):
                print(success)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
}
