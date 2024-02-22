//
//  StartStreamContract.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 22.02.2024.
//

import Foundation

protocol IStartStreamPresenter: AnyObject {
    func onFaceTapped()
    func onBodyTapped()
}

protocol IStartStreamView { }
