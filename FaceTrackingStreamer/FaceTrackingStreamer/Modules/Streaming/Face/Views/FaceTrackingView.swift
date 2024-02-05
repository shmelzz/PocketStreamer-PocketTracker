import UIKit
import ARKit

final class FaceTrackingViewController: UIViewController, IFaceTrackingView {
    
    // MARK: - Private properties
    
    private lazy var sceneView: ARSCNView = {
        return ARSCNView()
    }()
    
    // MARK: - DI
    
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
