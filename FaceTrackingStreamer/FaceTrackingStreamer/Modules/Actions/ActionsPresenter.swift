//
//  ActionsPresenter.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

final class ActionsPresenter: BaseModuleOutput, IActionsPresenter {
    
    // MARK: - DI
    
    private weak var view: IActionsView?
    
    private let actionsService: IActionsService
    private let actionsStorage: IActionsStorage
    
    init(
        actionsService: IActionsService,
        actionsStorage: IActionsStorage,
        view: IActionsView,
        coordinator: ICoordinator
    ) {
        self.view = view
        self.actionsService = actionsService
        self.actionsStorage = actionsStorage
        super.init(coordinator: coordinator)
        
        loadActionsList { [weak self] actions in
            self?.view?.setActionsView(with: actions)
        }
    }
    
    // MARK: - State
    
    private var actions: [ActionModel] = []
    
    // MARK: - IActionsPresenter
    
    func onViewReady() {
        loadActionsList { [weak self] actions in
            self?.view?.setActionsView(with: actions)
        }
    }
    
    func onActionTapped(with index: Int) {
        let action = actions[index]
        actionsService.send(action: action) { _ in }
    }
    
    func onActionTapped(_ actionModel: ActionRequestModel) {
        let model = ActionModel(displayName: "", payload: actionModel.payload, type: actionModel.type)
        actionsService.send(action: model) { [weak self] result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func onLongPress() {
        finish(.onLongPress)
    }
    
    // MARK: - Private
    
    private func loadActionsList(completion: @escaping ([ActionModel]) -> Void) {
        actionsService.getActionsList { [weak self] result in
            switch result {
            case .success(let data):
                self?.actions = data.actions
                self?.actionsStorage.set(data.actions)
                completion(data.actions)
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}
