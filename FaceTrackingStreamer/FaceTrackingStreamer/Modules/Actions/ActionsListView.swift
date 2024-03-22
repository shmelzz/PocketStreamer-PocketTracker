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
    
    private func setupView() {
        setupTableView()
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
