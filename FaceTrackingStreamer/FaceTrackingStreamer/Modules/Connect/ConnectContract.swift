//
//  ConnectContract.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 09.03.2024.
//

import Foundation

import Foundation

protocol IConnectPresenter {
    func onConnectTapped()
    func onConnectSuccess(with result: String)
    func onLogoutTapped()
    func onLongPress()
}

protocol IConnectView: AnyObject { }
