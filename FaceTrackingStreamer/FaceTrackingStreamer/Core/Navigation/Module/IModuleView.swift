//
//  IModuleView.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 31.03.2024.
//

import Foundation
import UIKit

protocol IModuleView<ViewInput, ViewOutput> {
    
    associatedtype ViewInput: UIView
    associatedtype ViewOutput
    
    var viewToPresent: ViewInput? { get }
    
    var viewOutput: ViewOutput { get }
}

final class ModuleView<ViewInput, ViewOutput>: IModuleView where ViewInput: UIView {
    
    typealias ViewInput = ViewInput
    typealias ViewOutput = ViewOutput
    
    private let _viewToPresent: ViewInput
    private let _viewOutput: ViewOutput
    
    init(viewToPresent: ViewInput, viewOutput: ViewOutput) {
        self._viewToPresent = viewToPresent
        self._viewOutput = viewOutput
    }
    
    lazy var viewToPresent: ViewInput? = {
        _viewToPresent
    }()
    
    lazy var viewOutput: ViewOutput = {
        _viewOutput
    }()
}
