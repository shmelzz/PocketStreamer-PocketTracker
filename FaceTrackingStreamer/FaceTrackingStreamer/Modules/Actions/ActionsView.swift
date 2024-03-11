//
//  ActionsView.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import Foundation
import UIKit

final class ActionsView: UIView, IActionsView {
    
    private enum Constants {
        static let stopRainText = "Stop rain"
        static let startRainText = "Start rain"
    }
    
    private lazy var rotateFrontButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Front", for: .normal)
        button.addTarget(self, action: #selector(onRotateFrontTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rotateSideButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Side", for: .normal)
        button.addTarget(self, action: #selector(onRotateSideTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var rainButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle(Constants.startRainText, for: .normal)
        button.addTarget(self, action: #selector(onRainTapped), for: .touchUpInside)
        return button
    }()
    
    private var rainIsRunningState: Bool = false
    
    var presenter: IActionsPresenter?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func viewDidLoad() {
//        setupView()
//    }
    
    private func setupView() {
        addSubview(rotateFrontButton)
        rotateFrontButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rotateFrontButton.topAnchor.constraint(equalTo: topAnchor),
            rotateFrontButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            rotateFrontButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        addSubview(rotateSideButton)
        rotateSideButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rotateSideButton.topAnchor.constraint(equalTo: rotateFrontButton.bottomAnchor, constant: 8),
            rotateSideButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            rotateSideButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
        
        addSubview(rainButton)
        rainButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rainButton.topAnchor.constraint(equalTo: rotateSideButton.bottomAnchor, constant: 8),
            rainButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            rainButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func onRotateFrontTapped() {
        presenter?.onActionTapped(ActionModel(payload: "0", type: "camera"))
    }
    
    @objc
    private func onRotateSideTapped() {
        presenter?.onActionTapped(ActionModel(payload: "1", type: "camera"))
    }
    
    @objc
    private func onRainTapped() {
        let type = rainIsRunningState ? "stoprain" : "startrain"
        presenter?.onActionTapped(ActionModel(payload: "", type: type))
        rainIsRunningState.toggle()
        
        if rainIsRunningState {
            rainButton.setTitle(Constants.stopRainText, for: .normal)
        } else {
            rainButton.setTitle(Constants.startRainText, for: .normal)
        }
    }
}
