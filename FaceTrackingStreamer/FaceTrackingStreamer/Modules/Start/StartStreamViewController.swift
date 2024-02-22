import UIKit

final class StartStreamViewController: UIViewController, IStartStreamView {
    
    private lazy var faceButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Face", for: .normal)
        button.addTarget(self, action: #selector(onFaceButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var bodyButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Body", for: .normal)
        button.addTarget(self, action: #selector(onBodyButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
    }
    
    private let apiStorage = ApiEndpointStorage(suiteName: "PocketTracker")
    private let authStorage = SessionStorage(suiteName: "PocketTracker")
    
    weak var presenter: IStartStreamPresenter?
    
    @objc
    private func onFaceButton() {
        let faceTrackingVC = OldFaceTrackingViewController(endpointStorage: apiStorage, authStorage: authStorage)
        
        navigationController?.pushViewController(
            faceTrackingVC,
            animated: true
        )
    }
    
    @objc
    private func onBodyButton() {
        navigationController?.pushViewController(BodyTrackingViewController(), animated: true)
    }
    
    // MARK: View setup
    
    private func setupView() {
        view.addSubview(faceButton)
        faceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            faceButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            faceButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            faceButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(bodyButton)
        bodyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyButton.topAnchor.constraint(equalTo: faceButton.bottomAnchor, constant: 16),
            bodyButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            bodyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}

