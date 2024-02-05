import UIKit

final class AuthViewController: UIViewController, UITextFieldDelegate {
    
    private lazy var nameTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Username"
        return field
    }()
    
    private lazy var passwordTextInput: UITextField = {
        let field = UITextField()
        field.placeholder = "Password"
        return field
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    weak var presenter: IAuthPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        view.addSubview(nameTextInput)
        nameTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            nameTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        nameTextInput.delegate = self
        
        view.addSubview(passwordTextInput)
        passwordTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextInput.topAnchor.constraint(equalTo: nameTextInput.bottomAnchor, constant: 16),
            passwordTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            passwordTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        passwordTextInput.delegate = self
        
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    @objc
    private func onLoginButtonTapped() {
        guard let name = nameTextInput.text,
              let password = passwordTextInput.text 
        else { return }
        
        presenter?.onLoginButtonTapped(with: AuthModel(username: name, password: password))
    }
    
    @objc
    private func onRegisterButtonTapped() {
        guard let name = nameTextInput.text,
              let password = passwordTextInput.text
        else { return }
        
        presenter?.onRegisterButtonTapped(with: AuthModel(username: name, password: password))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
}
