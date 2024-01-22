import UIKit

final class DebugMenuViewController: UIViewController, IDebugMenuView {
    
    private enum Constants {
        static let cellIdetifier = "DebugMenuCell"
    }
    
    private let tableView = UITableView()
    
    private lazy var dataSource = UITableViewDiffableDataSource<Int, UUID>(
        tableView: tableView
    ) { _, indexPath, itemIdentifier in
        let cell = DebugMenuCell(style: .subtitle, reuseIdentifier: Constants.cellIdetifier)
        return cell
    }
    
    private lazy var endpointTextInput: UITextField = {
        return UITextField()
    }()
    
    private lazy var portTextInput: UITextField = {
        return UITextField()
    }()
    
    private lazy var environmentControl: UISegmentedControl = {
        return UISegmentedControl(items: ["debug", "release"])
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(onButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var presenter: IDebugMenuPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter?.onViewReady()
    }
    
    // MARK: IDebugMenuView
    
    func setView(with model: ApiEndpoint) {
        portTextInput.text = model.port
        endpointTextInput.text = model.endpoint
    }
    
    // MARK: Private
    
    @objc
    private func onButtonTapped() {
        presenter?.onSaveButtonTappped(
            with: ApiEndpoint(
                endpoint: endpointTextInput.text ?? "",
                port: portTextInput.text ?? ""
            )
        )
    }
    
    // MARK: View setup
    
    private func setupView() {
//        view.addSubview(tableView)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
        view.addSubview(endpointTextInput)
        endpointTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endpointTextInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            endpointTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            endpointTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(portTextInput)
        portTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            portTextInput.topAnchor.constraint(equalTo: endpointTextInput.bottomAnchor, constant: 8),
            portTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            portTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(environmentControl)
        environmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            environmentControl.topAnchor.constraint(equalTo: portTextInput.bottomAnchor, constant: 8),
            environmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            environmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
