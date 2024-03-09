//
//  SessionProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol ISessionProvider: AnyObject {
    
    var token: String { get set }
    
    var sessionId: String { get set }
}

final class SessionProvider: ISessionProvider {
    
    private let authStorage: ISessionStorage
    
    init(authStorage: ISessionStorage) {
        self.authStorage = authStorage
        let data = authStorage.get()
        self.token = data?.token ?? ""
        self.sessionId = data?.sessionId ?? ""
    }
    
    var token: String
    
    var sessionId: String
}
