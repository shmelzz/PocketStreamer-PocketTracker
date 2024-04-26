//
//  MessageCell.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 11.03.2024.
//

import UIKit

final class MessageCell: UITableViewCell, ConfigurableView {
    
    static let messageCellId = "MessageCell"
    
    private enum Constants {
        static let greyColor = UIColor.systemGray
    }
    
    private lazy var message = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var senderName = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 11)
        label.textColor = .black
        return label
    }()
    
    private lazy var messageBubble = {
        let label = UIView()
        label.backgroundColor = .black
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.layer.opacity = 0.5
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupBubble()
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        message.isHidden = true
        message.text = nil
        messageBubble.backgroundColor = .black
    }
    
    // MARK: - ConfigurableView
    
    func configure(with model: MessageViewModel) {
        if model.isAction {
            messageBubble.backgroundColor = .systemPurple
        }
        message.isHidden = false
        message.text = model.message
        senderName.text = model.username
    }
    
    private func setupBubble() {
        senderName.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(senderName)
        NSLayoutConstraint.activate([
            senderName.topAnchor.constraint(equalTo: contentView.topAnchor),
            senderName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
        ])
        
        messageBubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageBubble)
        NSLayoutConstraint.activate([
            messageBubble.topAnchor.constraint(equalTo: senderName.bottomAnchor, constant: 4),
            messageBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageBubble.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            messageBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])

        message.translatesAutoresizingMaskIntoConstraints = false
        messageBubble.addSubview(message)
        NSLayoutConstraint.activate([
            message.topAnchor.constraint(equalTo: messageBubble.topAnchor, constant: 6),
            message.bottomAnchor.constraint(equalTo: messageBubble.bottomAnchor, constant: -6),
            message.trailingAnchor.constraint(equalTo: messageBubble.trailingAnchor, constant: -46),
            message.leadingAnchor.constraint(equalTo: messageBubble.leadingAnchor, constant: 12)
        ])
    }
}
