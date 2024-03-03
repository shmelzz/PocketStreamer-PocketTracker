import UIKit

final class StartStreamViewController: UIViewController, IStartStreamView, UIGestureRecognizerDelegate {
    
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
    
    private let longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = TimeInterval(1)
        return recognizer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        
        view.isUserInteractionEnabled = true
        faceButton.addGestureRecognizer(longTapGestureRecognizer)
        
        longTapGestureRecognizer.addTarget(self, action: #selector(onLongPress))
        longTapGestureRecognizer.delegate = self
    }
    
    var presenter: IStartStreamPresenter?
    
    @objc
    private func onFaceButton() {
        presenter?.onFaceTapped()
    }
    
    @objc
    private func onBodyButton() {
        navigationController?.pushViewController(BodyTrackingViewController(), animated: true)
        presenter?.onBodyTapped()
    }
    
    @objc
    private func onLongPress() {
        presenter?.onLongPress()
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
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

