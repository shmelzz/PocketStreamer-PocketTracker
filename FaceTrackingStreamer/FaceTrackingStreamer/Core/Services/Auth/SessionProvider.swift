//
//  SessionProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol ISessionProvider: AnyObject {
    
    var token: String? { get set }
    
    var sessionId: String? { get set }
    
    func reset()
}

final class SessionProvider: ISessionProvider {
    
    private let sessionStorage: ISessionStorage
    
    init(sessionStorage: ISessionStorage) {
        self.sessionStorage = sessionStorage
        let data = sessionStorage.get()
        self.token = data?.token ?? ""
        self.sessionId = data?.sessionId ?? ""
    }
    
    var token: String?
    
    var sessionId: String?
    
    func reset() {
        token = nil
        sessionId = nil
        sessionStorage.set(nil)
    }
}
