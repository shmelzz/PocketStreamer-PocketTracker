//
//  SelectPlatformContract.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import UIKit

struct SelectPlatformViewModel {
    let platform: StreamingPlatform
    let channel: String?
}

protocol ISelectPlatformPresenter: UIPickerViewDataSource, UIPickerViewDelegate {
    func onContinueTapped(platform name: String?)
    func onLongPress()
    func onViewReady()
}

protocol ISelectPlatformView: AnyObject {
    func configure(with model: SelectPlatformViewModel)
}
