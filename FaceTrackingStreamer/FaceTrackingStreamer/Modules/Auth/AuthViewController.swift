import UIKit

final class AuthViewController: UIViewController, IAuthView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private lazy var logoImageView: UIImageView = {
        let image = UIImage(named: "AppIcon")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    
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
        let button = UIButton(configuration: .plain())
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
    }()
    
    private let longTapGestureRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = TimeInterval(1)
        recognizer.addTarget(self, action: #selector(onLongPress))
        return recognizer
    }()
    
    var presenter: IAuthPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(tapGestureRecognizer)
        view.addGestureRecognizer(longTapGestureRecognizer)

        tapGestureRecognizer.cancelsTouchesInView = false
        longTapGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
        
        longTapGestureRecognizer.addTarget(self, action: #selector(onLongPress))
        longTapGestureRecognizer.delaysTouchesBegan = true
    }
    
    private func setupView() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        view.addSubview(nameTextInput)
        nameTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextInput.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 56),
            nameTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        nameTextInput.delegate = self
        
        view.addSubview(passwordTextInput)
        passwordTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextInput.topAnchor.constraint(equalTo: nameTextInput.bottomAnchor, constant: 24),
            passwordTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            passwordTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        passwordTextInput.delegate = self
        
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextInput.bottomAnchor, constant: 56),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(registerButton)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            registerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    // MARK: - Private
    
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
    
    @objc
    private func onViewTapped() {
        view.endEditing(true)
    }
    
    @objc
    private func onLongPress() {
        presenter?.onLongPress()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
