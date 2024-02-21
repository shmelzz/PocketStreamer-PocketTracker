//
//  SessionProvider.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 21.02.2024.
//

import Foundation

protocol ISessionProvider: AnyObject {
    
    var token: String { get }
    
    var sessionId: String { get }
}

final class SessionProvider: ISessionProvider {
    
    var token: String = ""
    
    var sessionId: String = ""
}
