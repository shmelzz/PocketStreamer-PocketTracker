//
//  ChatService.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation
import Starscream

struct MessageModel {
    let username: String
    let message: String
}

struct StreamModel {
    let platform: String
    let channel: String
}

protocol IChatService {
    func connect()
}

protocol IChatServiceDelegate: AnyObject {
    func didReceive()
}

final class ChatService: IChatService, WebSocketDelegate {

    private var webSocket: WebSocket?
    private let endpointProvider: IEndpointProvider
    private let requestBuilder: IRequestBuilder
    
    weak var delegate: IChatServiceDelegate?
    
    init(
        endpointProvider: IEndpointProvider,
        requestBuilder: IRequestBuilder
    ) {
        self.endpointProvider = endpointProvider
        self.requestBuilder = requestBuilder
    }
    
    // MARK: - WebSocketDelegate
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let dictionary):
            print("WebSocket connected")
        case .disconnected(let reason, let code):
            print("WebSocket disconnected: \(reason)")
        case .text(let text):
            print("Received text: \(text)")
        case .binary(let data):
            print("Received data: \(data)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            print("WebSocket cancelled")
        case .error(let error):
            print("WebSocket error: \(error?.localizedDescription ?? "Unknown error")")
        case .peerClosed:
            print()
        }
    }
    
    // MARK: - IFaceTrackingService
    
    func connect() {
        let endpoint = endpointProvider.streamingEndpoint()
        connect(to: endpoint)
    }
    
    // MARK: - Private
    
    private func connect(to domen: String) {
        guard let url = URL(string: "ws://\(domen)/message-trackered") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        webSocket = WebSocket(request: request)
        webSocket?.delegate = self
        webSocket?.connect()
    }
}
