//
//  ConfigurableView.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 11.03.2024.
//

import Foundation

protocol ConfigurableView {
    associatedtype ConfigurationModel
    func configure(with model: ConfigurationModel)
}
