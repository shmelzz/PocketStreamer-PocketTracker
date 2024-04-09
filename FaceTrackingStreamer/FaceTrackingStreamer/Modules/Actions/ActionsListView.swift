//
//  ActionsListView.swift
//  Pocket Streamer
//
//  Created by Elizaveta Shelemekh on 22.03.2024.
//

import UIKit

enum ActionSections: Hashable, CaseIterable {
    case actions
}

final class ActionsListView: UIView, IActionsView, UITableViewDelegate {
    
    private lazy var showActionsImage: UIImageView = {
        return UIImageView(image: ImageAssets.cubes)
    }()
    
    private lazy var showActionsButton: UIButton = {
        let button = UIButton.tinted(color: .black)
        button.addTarget(self, action: #selector(onShowActionsTap), for: .touchUpInside)
//        button.addGestureRecognizer(longTapGestureRecognizer)
        return button
    }()

    private lazy var tableView = UITableView(frame: .zero)
    
    private lazy var dataSource = DataSource(tableView)
    
    var presenter: IActionsPresenter?
    
    init() {
        super.init(frame: .zero)
        backgroundColor = .clear
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - IActionsView
    
    func setActionsView(with models: [ActionModel]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(models)
        dataSource.apply(snapshot)
    }
    
    // MARK: - Private
    
    @objc
    private func onShowActionsTap() {
        tableView.isHidden.toggle()
    }
    
    private func setupView() {
        addSubview(showActionsButton)
        showActionsButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showActionsButton.topAnchor.constraint(equalTo: topAnchor),
            showActionsButton.widthAnchor.constraint(equalToConstant: 52),
            showActionsButton.heightAnchor.constraint(equalToConstant: 52),
            showActionsButton.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        showActionsButton.addSubview(showActionsImage)
        showActionsImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showActionsImage.topAnchor.constraint(equalTo: showActionsButton.topAnchor, constant: 4),
            showActionsImage.trailingAnchor.constraint(equalTo: showActionsButton.trailingAnchor, constant: -4),
            showActionsImage.bottomAnchor.constraint(equalTo: showActionsButton.bottomAnchor, constant: -4),
            showActionsImage.leadingAnchor.constraint(equalTo: showActionsButton.leadingAnchor, constant: 4)
        ])
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: showActionsButton.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.register(ActionCell.self, forCellReuseIdentifier: ActionCell.actionCellId)
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.actions])
        dataSource.apply(snapshot)
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.onActionTapped(with: indexPath.row)
    }
}

// MARK: - Data source

final private class DataSource: UITableViewDiffableDataSource<ActionSections, ActionModel> {
    
    init(_ tableView: UITableView) {
        super.init(tableView: tableView) { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: ActionCell.actionCellId, for: indexPath) as? ActionCell
            cell?.configure(with: itemIdentifier)
            return cell
        }
    }
}
