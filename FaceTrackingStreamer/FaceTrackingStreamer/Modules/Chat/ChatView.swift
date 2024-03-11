//
//  ChatView.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 10.03.2024.
//

import UIKit

enum MessageSections: Hashable, CaseIterable {
    case messages
}

final class ChatView: UIView, IChatView, UITableViewDelegate {
    
    private enum Constants {
        static let followChatText = "Follow chat"
    }
    
    private lazy var tableView = UITableView(frame: .zero)
    
    private lazy var dataSource = DataSource(tableView)
    
    private lazy var followChatButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle(Constants.followChatText, for: .normal)
        button.addTarget(self, action: #selector(onfollowChatTapped), for: .touchUpInside)
        return button
    }()
    
    var presenter: IChatPresenter?
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IChatView
    
    func onNewMessage(_ model: MessageModel) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems([model], toSection: .messages)
        dataSource.apply(snapshot)
        print(model.message)
    }
    
    // MARK: - Private
    
    private func setupView() {
        addSubview(followChatButton)
        followChatButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            followChatButton.topAnchor.constraint(equalTo: topAnchor),
            followChatButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            followChatButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8)
        ])
        
        
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.messageCellId)
    }
    
    @objc
    private func onfollowChatTapped() {
        presenter?.onFollowChat()
    }
    
//    private func scrollToBottomMessage(_ count: Int) {
//        if count >= 1 {
//            let bottomMessageIndex = IndexPath(row: count - 1, section: 0)
//            tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
//        }
//    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Data source

final private class DataSource: UITableViewDiffableDataSource<MessageSections, MessageModel> {
    
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.messageCellId, for: indexPath) as? MessageCell
            cell?.configure(with: itemIdentifier)
            return cell
        }
    }
}
