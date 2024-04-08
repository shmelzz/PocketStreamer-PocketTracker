//
//  ConnectViewController.swift
//  FaceTrackingStreamer
//
//  Created by Elizaveta Shelemekh on 09.03.2024.
//

import UIKit
import CameraManager

final class ConnectViewController: UIViewController, IConnectView, UIGestureRecognizerDelegate {
    
    private enum Constants {
        static let startScanText = "Connect to PocketComposer"
        static let stopScanText = "Stop scanning"
    }
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.connectCircle)
        return view
    }()
    
    private lazy var connectButton: UIButton = {
        let button = UIButton.tinted(
            title: Constants.startScanText,
            font: Fonts.redditMonoMedium
        )
        button.tintColor = .white
        button.addTarget(self, action: #selector(onConnectButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(onLogoutButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var scanView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.isHidden = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = TimeInterval(1)
        return recognizer
    }()
    
    private let cameraManager = CameraManager()
    
    var presenter: IConnectPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        
        view.isUserInteractionEnabled = true
        connectButton.addGestureRecognizer(longTapGestureRecognizer)
        
        longTapGestureRecognizer.addTarget(self, action: #selector(onLongPress))
        longTapGestureRecognizer.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    @objc
    private func onConnectButton() {
        if scanView.isHidden {
            startScan()
        } else {
            stopScan()
        }
    }
    
    private func startScan() {
        connectButton.reconfigureTitle(Constants.stopScanText)
        cameraManager.startQRCodeDetection { [weak self] result in
            switch result {
            case .success(let value):
                self?.cameraManager.stopQRCodeDetection()
                self?.presenter?.onConnectSuccess(with: value)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        UIView.animate(withDuration: 0.6) {
            self.imageView.alpha = 0
        } completion: { _ in
            self.scanView.isHidden = false
        }
    }
    
    private func stopScan() {
        connectButton.reconfigureTitle(Constants.startScanText)
        cameraManager.stopQRCodeDetection()
        
        UIView.animate(withDuration: 0.6) {
            self.imageView.alpha = 1
            self.scanView.isHidden = true
        }
    }
    
    @objc
    private func onLongPress() {
        presenter?.onLongPress()
    }
    
    @objc
    private func onLogoutButton() {
        presenter?.onLogoutTapped()
    }
    
    // MARK: View setup
    
    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)
        
        view.addSubview(connectButton)
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 100),
            connectButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            connectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            connectButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        view.addSubview(scanView)
        scanView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scanView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            scanView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            scanView.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -16),
            scanView.heightAnchor.constraint(equalTo: scanView.widthAnchor)
        ])
        cameraManager.addPreviewLayerToView(scanView)
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            imageView.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
}
