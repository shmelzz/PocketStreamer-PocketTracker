import UIKit

final class DebugMenuViewController: UIViewController, IDebugMenuView, UITextFieldDelegate {

    // MARK: - Views
    
    private lazy var prodLabel: UILabel = {
        let view = UILabel()
        view.text = "Prod environment"
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    private lazy var prodEndpointTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Endpoint"
        return field
    }()
    
    private lazy var prodPortTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Port"
        return field
    }()
    
    private lazy var testLabel: UILabel = {
        let view = UILabel()
        view.text = "Test environment"
        view.font = .boldSystemFont(ofSize: 17)
        return view
    }()
    
    private lazy var testEndpointTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Endpoint"
        return field
    }()
    
    private lazy var testPortTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Port"
        return field
    }()
    
    private lazy var environmentControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["prod", "test"])
        return view
    }()
    
    private lazy var mockControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["use mocks", "use real data"])
        return view
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
    
    var presenter: IDebugMenuPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupView()
        presenter?.onViewReady()
        
        prodPortTextInput.isHidden = true
        testPortTextInput.isHidden = true
    }
    
    // MARK: - IDebugMenuView
        
    func setView(with model: DebugMenuModel) {
        let prodModel = model.environments?.environments.first(where: { $0.environment == .prod })
        let testModel = model.environments?.environments.first(where: { $0.environment == .test })
        let selectedEnv = model.environments?.environments.first(where: { $0.isSelected })?.environment
        
        prodPortTextInput.text = prodModel?.endpoint.port
        prodEndpointTextInput.text = prodModel?.endpoint.endpoint
        
        testPortTextInput.text = testModel?.endpoint.port
        testEndpointTextInput.text = testModel?.endpoint.endpoint
        
        environmentControl.selectedSegmentIndex = selectedEnv == .prod ? 0 : 1
        
        sessionIdTextInput.text = model.authData?.sessionId
        jwtTokenTextInput.text = model.authData?.token
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: Private
    
    @objc
    private func onButtonTapped() {
        let selectedEnvironment: EnvironmentEndpoint.EnvironmentType = (environmentControl.selectedSegmentIndex == 0) ? .prod : .test
        
        let prodEndpointModel = EnvironmentEndpoint(
            environment: .prod,
            endpoint: ApiEndpoint(
                endpoint: prodEndpointTextInput.text ?? "",
                port: prodPortTextInput.text ?? ""
            ),
            isSelected: selectedEnvironment == .prod
        )
        
        let testEndpointModel = EnvironmentEndpoint(
            environment: .test,
            endpoint: ApiEndpoint(
                endpoint: testEndpointTextInput.text ?? "",
                port: testPortTextInput.text ?? ""
            ),
            isSelected: selectedEnvironment == .test
        )
        
        let authModel = AuthData(
            sessionId: sessionIdTextInput.text ?? "",
            token: jwtTokenTextInput.text ?? ""
        )
        
        let envs = Environments(environments: [prodEndpointModel, testEndpointModel])
        let debugModel = DebugMenuModel(environments: envs, authData: authModel)
        
        presenter?.onSaveButtonTappped(with: debugModel)
        
        dismiss(animated: true)
    }
    
    // MARK: View setup
    
    private func setupView() {
        // Prod
        
        view.addSubview(prodLabel)
        prodLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prodLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            prodLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            prodLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(prodEndpointTextInput)
        prodEndpointTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prodEndpointTextInput.topAnchor.constraint(equalTo: prodLabel.bottomAnchor, constant: 16),
            prodEndpointTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            prodEndpointTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        prodEndpointTextInput.delegate = self
        
        view.addSubview(prodPortTextInput)
        prodPortTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            prodPortTextInput.topAnchor.constraint(equalTo: prodEndpointTextInput.bottomAnchor, constant: 16),
            prodPortTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            prodPortTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        prodPortTextInput.delegate = self
        
        // Test
        
        view.addSubview(testLabel)
        testLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testLabel.topAnchor.constraint(equalTo: prodPortTextInput.bottomAnchor, constant: 26),
            testLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            testLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(testEndpointTextInput)
        testEndpointTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testEndpointTextInput.topAnchor.constraint(equalTo: testLabel.bottomAnchor, constant: 16),
            testEndpointTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            testEndpointTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        testEndpointTextInput.delegate = self
        
        view.addSubview(testPortTextInput)
        testPortTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            testPortTextInput.topAnchor.constraint(equalTo: testEndpointTextInput.bottomAnchor, constant: 16),
            testPortTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            testPortTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        testPortTextInput.delegate = self
        
        // Env control
        
        view.addSubview(environmentControl)
        environmentControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            environmentControl.topAnchor.constraint(equalTo: testPortTextInput.bottomAnchor, constant: 26),
            environmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            environmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        // Auth
        
        view.addSubview(sessionIdTextInput)
        sessionIdTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sessionIdTextInput.topAnchor.constraint(equalTo: environmentControl.bottomAnchor, constant: 26),
            sessionIdTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            sessionIdTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        sessionIdTextInput.delegate = self
        
        view.addSubview(jwtTokenTextInput)
        jwtTokenTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            jwtTokenTextInput.topAnchor.constraint(equalTo: sessionIdTextInput.bottomAnchor, constant: 16),
            jwtTokenTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            jwtTokenTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        jwtTokenTextInput.delegate = self
        
        view.addSubview(mockControl)
        mockControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mockControl.topAnchor.constraint(equalTo: jwtTokenTextInput.bottomAnchor, constant: 26),
            mockControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mockControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
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
