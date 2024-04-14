import UIKit
import ARKit

final class FaceTrackingViewController: UIViewController, IFaceTrackingView {
    
    // MARK: - Private properties
    
    private lazy var sceneView: ARSCNView = {
        return ARSCNView()
    }()
    
    private lazy var faceNode: SCNNode = {
        SCNNode()
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Connect", for: .normal)
        button.addTarget(self, action: #selector(onConnectTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Settings", for: .normal)
        button.addTarget(self, action: #selector(onSettingsTapped), for: .touchUpInside)
        return button
    }()
    
    private let actionsListView: UIView?
    
    private let chatView: UIView?
    
//    private lazy var actionsCameraView: ActionsListView = {
//        let view = ActionsListView()
//        let presenter = ActionsPresenter(
//            actionsService: actionsService,
//            view: view,
//            coordinator: coordinator
//        )
//        view.presenter = presenter
//        return view
//    }()
    
    // MARK: - DI
    var presenter: IFaceTrackingPresenter?
    
    // MARK: - Init
    
    init(
        actionsListView: UIView?,
        chatView: UIView?
    ) {
        self.actionsListView = actionsListView
        self.chatView = chatView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
    
    // MARK: - Private
    
    @objc
    private func onSettingsTapped() {

    }
    
    @objc
    private func onConnectTapped() {

    }
}
