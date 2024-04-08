//
//  SelectPlatformContract.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import UIKit

protocol ISelectPlatformPresenter: UIPickerViewDataSource, UIPickerViewDelegate {
    func onContinueTapped(platform name: String?)
    func onLongPress()
}

protocol ISelectPlatformView: AnyObject { }
