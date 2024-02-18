import UIKit

final class DebugMenuViewController: UIViewController, IDebugMenuView, UITextFieldDelegate {
    
//    private enum Constants {
//        static let cellIdetifier = "DebugMenuCell"
//    }
//    
//    private let tableView = UITableView()
//    
//    private lazy var dataSource = UITableViewDiffableDataSource<Int, UUID>(
//        tableView: tableView
//    ) { _, indexPath, itemIdentifier in
//        let cell = DebugMenuCell(style: .subtitle, reuseIdentifier: Constants.cellIdetifier)
//        return cell
//    }
    
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
    
    private lazy var sessionIdTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Session Id"
        return field
    }()
    
    private lazy var jwtTokenTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "JWT Token"
        return field
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
    
    func setView(with model: DebugMenuModel) {
        portTextInput.text = model.endpoint.port
        endpointTextInput.text = model.endpoint.endpoint
        
        sessionIdTextInput.text = model.authData.sessionId
        jwtTokenTextInput.text = model.authData.token
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: Private
    
    @objc
    private func onButtonTapped() {
        // let env: ApiEndpoint.Environment = (environmentControl.selectedSegmentIndex == 0) ? .debug : .release
        
        let endpointModel = ApiEndpoint(
            // environment: env,
            endpoint: endpointTextInput.text ?? "",
            port: portTextInput.text ?? ""
        )
        
        let authModel = AuthData(
            sessionId: sessionIdTextInput.text ?? "",
            token: jwtTokenTextInput.text ?? ""
        )
        
        presenter?.onSaveButtonTappped(with: endpointModel)
        
        let model = DebugMenuModel(endpoint: endpointModel, authData: authModel)
        
        // presenter?.onSaveButtonTappped(with: model)
        
        dismiss(animated: true)
    }
    
    // MARK: View setup
    
    private func setupView() {
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
        
        view.addSubview(sessionIdTextInput)
        sessionIdTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sessionIdTextInput.topAnchor.constraint(equalTo: environmentControl.bottomAnchor, constant: 16),
            sessionIdTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sessionIdTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(jwtTokenTextInput)
        jwtTokenTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            jwtTokenTextInput.topAnchor.constraint(equalTo: sessionIdTextInput.bottomAnchor, constant: 16),
            jwtTokenTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            jwtTokenTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            saveButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
