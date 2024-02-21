import Foundation
import UIKit

protocol IModule {
    var viewToPresent: UIViewController? { get }
}

extension UIViewController: IModule {
    
    var viewToPresent: UIViewController? {
        return self
    }
}
