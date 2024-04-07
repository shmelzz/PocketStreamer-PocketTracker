import UIKit

final class AuthViewController: UIViewController, IAuthView, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private lazy var backgroundImage: UIImageView = {
        let view = UIImageView(image: ImageAssets.backBlack)
        return view
    }()
    
    private lazy var logoImageView: UIImageView = {
        let image = UIImage(named: "AppIcon")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var nameTextInput: UITextField = {
        let field = UITextField.blackTinted(pleceholderText: "Username")
        field.setLeftView(UIImageView(image: ImageAssets.account), padding: 16)
        return field
    }()
    
    private lazy var passwordTextInput: UITextField = {
        let field = UITextField.blackTinted(pleceholderText: "Password")
        field.isSecureTextEntry = true
        field.setLeftView(UIImageView(image: ImageAssets.key), padding: 16)
        field.setRightView(hidePasswordImageView, padding: 20)
        return field
    }()
    
    private lazy var hidePasswordImageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.eye)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hidePasswordGestureRecognizer)
        return view
    }()
    
    private lazy var showPasswordImageView: UIImageView = {
        let view = UIImageView(image: ImageAssets.eyeCross)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(hidePasswordGestureRecognizer)
        return view
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton.tinted(
            title: "Sign In",
            font: Fonts.redditMonoSemiBold
        )
        button.tintColor = .black
        button.addTarget(self, action: #selector(onLoginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerButton: UIButton = {
        let button = UIButton.tinted(
            title: "Don't have an account? Register",
            font: Fonts.redditMonoLight
        )
        button.tintColor = .black
        button.addTarget(self, action: #selector(onRegisterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onViewTapped))
    }()
    
    private lazy var hidePasswordGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(onHidePasswordTapped))
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
        view.backgroundColor = .systemBackground
        
        setupView()
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(tapGestureRecognizer)
        view.addGestureRecognizer(longTapGestureRecognizer)

        tapGestureRecognizer.cancelsTouchesInView = false
        longTapGestureRecognizer.delegate = self
        tapGestureRecognizer.delegate = self
        
        longTapGestureRecognizer.addTarget(self, action: #selector(onLongPress))
        longTapGestureRecognizer.delaysTouchesBegan = true
        
        presenter?.onViewReady()
    }
    
    private func setupView() {
        view.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            logoImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 150),
            logoImageView.widthAnchor.constraint(equalToConstant: 150)
        ])
        
        view.addSubview(nameTextInput)
        nameTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameTextInput.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 80),
            nameTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextInput.heightAnchor.constraint(equalToConstant: 48)
        ])
        nameTextInput.delegate = self
        
        view.addSubview(passwordTextInput)
        passwordTextInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordTextInput.topAnchor.constraint(equalTo: nameTextInput.bottomAnchor, constant: 20),
            passwordTextInput.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            passwordTextInput.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            passwordTextInput.heightAnchor.constraint(equalToConstant: 48)
        ])
        passwordTextInput.delegate = self
        
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordTextInput.bottomAnchor, constant: 72),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        view.addSubview(registerButton)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
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
    private func onHidePasswordTapped() {
        if passwordTextInput.isSecureTextEntry {
            passwordTextInput.setRightView(showPasswordImageView, padding: 20)
        } else {
            passwordTextInput.setRightView(hidePasswordImageView, padding: 20)
        }
        passwordTextInput.isSecureTextEntry.toggle()
    }
    
    @objc
    private func onLongPress() {
        presenter?.onLongPress()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
