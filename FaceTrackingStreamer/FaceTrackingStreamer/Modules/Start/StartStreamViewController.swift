import UIKit

final class StartStreamViewController: UIViewController, IStartStreamView, UIGestureRecognizerDelegate {
    
    private lazy var backgroundImage: UIImageView = {
        let view = UIImageView(image: ImageAssets.backNavy)
        return view
    }()
    
    private lazy var faceImageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.faceMesh)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var faceButton: UIButton = {
        let button = UIButton.tinted(
            title: "Face",
            font: Fonts.redditMonoMedium
        )
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(onFaceButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var bodyImageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.bodyMesh)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var bodyButton: UIButton = {
        let button = UIButton.tinted(
            title: "Body",
            font: Fonts.redditMonoMedium
        )
        button.tintColor = .lightGray
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
        view.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(faceImageView)
        faceImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            faceImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            faceImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            faceImageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            faceImageView.heightAnchor.constraint(equalTo: faceImageView.widthAnchor, multiplier: 1.4)
        ])
        
        view.addSubview(faceButton)
        faceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            faceButton.topAnchor.constraint(equalTo: faceImageView.bottomAnchor, constant: 16),
            faceButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            faceButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            faceButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        view.addSubview(bodyImageView)
        bodyImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            bodyImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            bodyImageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            bodyImageView.heightAnchor.constraint(equalTo: bodyImageView.widthAnchor, multiplier: 1.4)
        ])
        
        view.addSubview(bodyButton)
        bodyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyButton.topAnchor.constraint(equalTo: bodyImageView.bottomAnchor, constant: 16),
            bodyButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            bodyButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            bodyButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}

