//
//  SelectPlatformViewController.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation
import UIKit

final class SelectPlatformViewController: UIViewController, ISelectPlatformView, UIGestureRecognizerDelegate, UITextFieldDelegate {
        
    private lazy var backgroundImage: UIImageView = {
        let view = UIImageView(image: ImageAssets.backRainbow)
        return view
    }()
    
    private lazy var smileImageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.smile)
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton.tinted(
            title: "Continue",
            font: Fonts.redditMonoMedium
        )
        button.tintColor = .white
        button.addTarget(self, action: #selector(onContinueTapped), for: .touchUpInside)
        button.addGestureRecognizer(longTapGestureRecognizer)
        return button
    }()
    
    //    private lazy var pickerView: UIPickerView = {
    //        let view = UIPickerView()
    //        view.dataSource = presenter
    //        view.delegate = presenter
    //        return view
    //    }()
    
    private lazy var pickerView: UIButton = {
        let button = UIButton.tinted(
            title: "Twitch",
            font: Fonts.redditMonoRegular
        )
        button.layer.cornerRadius = 20
        button.tintColor = .white
        return button
    }()
    
    private lazy var channelTextInput: UITextField = {
        let field = UITextField.blackTinted(pleceholderText: "Channel")
        field.textAlignment = .center
        field.backgroundColor = .white.withAlphaComponent(0.2)
        field.attributedPlaceholder = NSAttributedString(
            AttributedString(
                "Channel",
                attributes: AttributeContainer([
                    NSAttributedString.Key.font: Fonts.redditMonoExtraLight,
                    NSAttributedString.Key.foregroundColor: UIColor.systemGray
                ])
            )
        )
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
        
        presenter?.onViewReady()
    }
    
    // MARK: - ISelectPlatformView

    func configure(with model: SelectPlatformViewModel) {
        channelTextInput.text = model.channel
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
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
        view.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(smileImageView)
        smileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            smileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            smileImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            smileImageView.heightAnchor.constraint(equalToConstant: 150),
            smileImageView.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: smileImageView.bottomAnchor, constant: 32),
            pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        view.addSubview(channelTextInput)
        channelTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            channelTextInput.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 24),
            channelTextInput.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            channelTextInput.widthAnchor.constraint(equalToConstant: 200),
            channelTextInput.heightAnchor.constraint(equalToConstant: 48)
        ])
        channelTextInput.delegate = self
        
        view.addSubview(continueButton)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.topAnchor.constraint(equalTo: channelTextInput.bottomAnchor, constant: 72),
            continueButton.widthAnchor.constraint(equalToConstant: 150),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
