//
//  ActionsService.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IActionsService {
    func send(action model: ActionRequestModel, completion: @escaping (Result<EmptyResponse, Error>) -> Void)
    func getActionsList( completion: @escaping (Result<ActionsList, Error>) -> Void)
}

final class ActionsService: IActionsService {

    private let requestManager: IRequestManager
    private let endpointProvider: IEndpointProvider
    private let sessionProvider: ISessionProvider
    
    init(
        requestManager: IRequestManager,
        endpointProvider: IEndpointProvider,
        sessionProvider: ISessionProvider
    ) {
        self.requestManager = requestManager
        self.endpointProvider = endpointProvider
        self.sessionProvider = sessionProvider
    }
    
    func send(action model: ActionRequestModel, completion: @escaping (Result<EmptyResponse, Error>) -> Void){
        let request = ActionRequest(
            payload: model.payload,
            type: model.type,
            sessionId: sessionProvider.sessionId ?? "",
            endpoint: endpointProvider.actionEndpoint()
        )
        requestManager.execute(request: request, completion: completion)
    }
    
    func getActionsList(completion: @escaping (Result<ActionsList, Error>) -> Void) {
        let request = ActionsListRequest(
            sessionId: sessionProvider.sessionId ?? "",
            endpoint: endpointProvider.actionEndpoint()
        )
        requestManager.execute(request: request, completion: completion)
    }
}
