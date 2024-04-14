//
//  ActionCell.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 22.03.2024.
//

import UIKit

final class ActionCell: UITableViewCell, ConfigurableView {
    
    static let actionCellId = "ActionCell"
    
    private enum Constants {
        static let backColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    private lazy var actionName = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = Fonts.redditMonoRegular
        return label
    }()
    
    private lazy var actionBubble = {
        let label = UIView()
        label.backgroundColor = Constants.backColor
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
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
        actionName.isHidden = true
        actionName.text = nil
    }
    
    // MARK: - ConfigurableView
    
    func configure(with model: ActionModel) {
        actionName.isHidden = false
        actionName.text = model.displayName
    }
    
    private func setupBubble() {
        actionBubble.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionBubble)
        NSLayoutConstraint.activate([
            actionBubble.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            actionBubble.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            actionBubble.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            actionBubble.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            actionBubble.heightAnchor.constraint(equalToConstant: 40)
        ])

        actionName.translatesAutoresizingMaskIntoConstraints = false
        actionBubble.addSubview(actionName)
        NSLayoutConstraint.activate([
            actionName.topAnchor.constraint(equalTo: actionBubble.topAnchor, constant: 6),
            actionName.bottomAnchor.constraint(equalTo: actionBubble.bottomAnchor, constant: -6),
            actionName.trailingAnchor.constraint(equalTo: actionBubble.trailingAnchor, constant: -12),
            actionName.leadingAnchor.constraint(equalTo: actionBubble.leadingAnchor, constant: 12)
        ])
    }
}
