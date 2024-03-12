//
//  SelectPlatformViewController.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation
import UIKit

final class SelectPlatformViewController: UIViewController, ISelectPlatformView, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Continue", for: .normal)
        button.addTarget(self, action: #selector(onContinueTapped), for: .touchUpInside)
        button.addGestureRecognizer(longTapGestureRecognizer)
        return button
    }()
    
    private lazy var channelTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Channel"
        field.textAlignment = .center
        return field
    }()
    
    private let longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = TimeInterval(1)
        return recognizer
    }()
    
    var presenter: ISelectPlatformPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        
        view.isUserInteractionEnabled = true
        continueButton.addGestureRecognizer(longTapGestureRecognizer)
        
        longTapGestureRecognizer.addTarget(self, action: #selector(onLongPress))
        longTapGestureRecognizer.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    @objc
    private func onContinueTapped() {
        let text = channelTextInput.text
        presenter?.onContinueTapped(platform: text)
    }
    
    @objc
    private func onLongPress() {
        presenter?.onLongPress()
    }
    
    // MARK: View setup
    
    private func setupView() {
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(channelTextInput)
        channelTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            channelTextInput.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -32),
            channelTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            channelTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        channelTextInput.delegate = self
    }
}
