//
//  StartStreamContract.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 22.02.2024.
//

import Foundation

protocol IStartStreamPresenter {
    func onFaceTapped()
    func onBodyTapped()
    func onLongPress()
}

protocol IStartStreamView: AnyObject { }
