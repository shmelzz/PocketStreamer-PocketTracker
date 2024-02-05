import UIKit

final class DebugMenuViewController: UIViewController, IDebugMenuView, UITextFieldDelegate {
    
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
        let field = UITextField()
        field.placeholder = "Endpoint"
        return field
    }()
    
    private lazy var portTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Port"
        return field
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
        view.backgroundColor = .systemBackground
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
        // let env: ApiEndpoint.Environment = (environmentControl.selectedSegmentIndex == 0) ? .debug : .release
        presenter?.onSaveButtonTappped(
            with: ApiEndpoint(
                // environment: env,
                endpoint: endpointTextInput.text ?? "",
                port: portTextInput.text ?? ""
            )
        )
        dismiss(animated: true)
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
            endpointTextInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            endpointTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            endpointTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        endpointTextInput.delegate = self
        
        view.addSubview(portTextInput)
        portTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            portTextInput.topAnchor.constraint(equalTo: endpointTextInput.bottomAnchor, constant: 16),
            portTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            portTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        portTextInput.delegate = self
        
        view.addSubview(environmentControl)
        environmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            environmentControl.topAnchor.constraint(equalTo: portTextInput.bottomAnchor, constant: 16),
            environmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            environmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
