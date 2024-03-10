//
//  FindComposerService.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation

protocol IFindComposerService {
    func find(completion: @escaping (Result<EmptyResponse, Error>) -> Void)
}

final class FindComposerService: IFindComposerService {

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
    
    func find(completion: @escaping (Result<EmptyResponse, Error>) -> Void) {
        let request = ComposerRequest(
            sessionId: sessionProvider.sessionId ?? "",
            endpoint: endpointProvider.authEndpoint()
        )
        requestManager.execute(request: request, completion: completion)
    }
}
