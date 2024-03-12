//
//  ChatService.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation
import Starscream
import SwiftyJSON

struct MessageModel: Hashable, Decodable, JSONParsable {
    let username: String
    let message: String
}

struct StreamModel {
    let platform: String
    let channel: String
}

protocol IChatService {
    func connect(model: StreamModel)
    func setDelegate(_ delegate: IChatServiceDelegate)
}

protocol IChatServiceDelegate: AnyObject {
    func didReceive(new message: MessageModel)
}

final class ChatService: IChatService, WebSocketDelegate {
    
    private var webSocket: WebSocket?
    private let endpointProvider: IEndpointProvider
    private let requestBuilder: IRequestBuilder
    private let sessionProvider: ISessionProvider
    
    weak var delegate: IChatServiceDelegate?
    
    init(
        endpointProvider: IEndpointProvider,
        requestBuilder: IRequestBuilder,
        sessionProvider: ISessionProvider
    ) {
        self.endpointProvider = endpointProvider
        self.requestBuilder = requestBuilder
        self.sessionProvider = sessionProvider
    }
    
    // MARK: - WebSocketDelegate
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let dictionary):
            print("Chat WebSocket connected")
        case .disconnected(let reason, let code):
            print("Chat WebSocket disconnected: \(reason)")
        case .text(let text):
            let json = JSON(parseJSON: text)
            let model = try? MessageModel.from(json)
            guard let username = model?.username,
                  let message = model?.message else { return }
            delegate?.didReceive(new: MessageModel(username: username, message: message))
            print("Received text: \(text)")
        case .binary(let data):
            let decoded = try? JSONDecoder().decode(MessageModel.self, from: data)
            guard let username = decoded?.username,
                  let message = decoded?.message else { return }
            delegate?.didReceive(new: MessageModel(username: username, message: message))
            print("Received data: \(message) from \(username)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("Chat WebSocket cancelled")
        case .error(let error):
            print("Chat WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .peerClosed:
            print()
        }
    }
    
    // MARK: - IFaceTrackingService
    
    func connect(model: StreamModel) {
        let endpoint = endpointProvider.streamingEndpoint()
        connect(to: endpoint, model: model)
    }
    
    func setDelegate(_ delegate: IChatServiceDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Private
    
    private func connect(to domen: String, model: StreamModel) {
        guard let url = URL(string: "ws://\(domen)/message-trackered") else { return }
        var request = URLRequest(url: url)
        
        request.setValue(model.platform, forHTTPHeaderField: "Platform")
        request.setValue(model.channel, forHTTPHeaderField: "Channel")
        request.setValue(sessionProvider.token, forHTTPHeaderField: "Authentication")
        request.setValue(sessionProvider.sessionId, forHTTPHeaderField: "SessionId")
        
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
}
