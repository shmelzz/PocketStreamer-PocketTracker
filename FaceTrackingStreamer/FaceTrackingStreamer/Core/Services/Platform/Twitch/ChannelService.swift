//
//  ChannelService.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh
//

import Foundation

protocol IChannelService {
    func validate(channel: ChannelModel, completion: @escaping (Result<ChannelValidationModel, Error>) -> Void)
}

final class ChannelService: IChannelService {

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
    
    func validate(channel: ChannelModel, completion: @escaping (Result<ChannelValidationModel, Error>) -> Void) {
        let request = ChannelValidationRequest(
            channelName: channel.channel,
            sessionId: sessionProvider.sessionId ?? "",
            endpoint: endpointProvider.streamingEndpoint()
        )
        requestManager.execute(request: request, completion: completion)
    }
}
