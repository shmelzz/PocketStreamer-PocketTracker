import UIKit

final class DebugMenuViewController: UIViewController {
    
    private enum Constants {
        static let cellIdetifier = "DebugMenuCell"
    }
    
    private let tableView = UITableView()
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, UUID>(
        tableView: tableView) { _, indexPath, itemIdentifier in
            let cell = DebugMenuCell(style: .subtitle, reuseIdentifier: Constants.cellIdetifier)
            return cell
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        
    }
    
}
