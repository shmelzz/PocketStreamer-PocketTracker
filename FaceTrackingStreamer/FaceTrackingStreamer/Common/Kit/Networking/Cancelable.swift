//
//  Cancelable.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 20.02.2024.
//

import Foundation

protocol Cancelable {
    func cancel()
}

final class DefaultCancelable: Cancelable {
    func cancel() {}
}
