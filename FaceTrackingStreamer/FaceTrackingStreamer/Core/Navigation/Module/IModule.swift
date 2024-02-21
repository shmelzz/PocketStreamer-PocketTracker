import Foundation
import UIKit

protocol IModule<ViewInput, ViewOutput> {
    
    associatedtype ViewInput: UIViewController
    associatedtype ViewOutput
    
    var viewToPresent: ViewInput? { get }
    
    var viewOutput: ViewOutput { get }
}

final class Module<ViewInput, ViewOutput>: IModule where ViewInput: UIViewController {
    
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
