//
//  AthorizationView.swift
//  VkClient
//
//  Created by Ruslan Kozlov on 17.04.2024.
//

import UIKit

protocol AuthorizationViewDelegate: AnyObject {
    func didLoginButtonTapped(email: String, password: String)
    func didTapRegister()
}

class AuthorizationView: UIView {

    weak var delegate: AuthorizationViewDelegate?

    var fieldStackView: UIStackView = {
        let fieldStackView = UIStackView()
        fieldStackView.axis = .vertical
        fieldStackView.spacing = 10
        fieldStackView.alignment = .fill
        fieldStackView.distribution = .fillEqually
        fieldStackView.translatesAutoresizingMaskIntoConstraints = false
        return fieldStackView
    }()

    var loginTextField: UITextField = {
        let loginTextField = UITextField()
        loginTextField.keyboardType = .emailAddress
        loginTextField.placeholder = "email..."
        loginTextField.autocorrectionType = .no
        loginTextField.autocapitalizationType = .none
        loginTextField.backgroundColor = .white
        loginTextField.returnKeyType = .continue
        loginTextField.borderStyle = .roundedRect
        loginTextField.textColor = .black
        loginTextField.tintColor = .black
        return loginTextField
    }()

    var passwordTextField: UITextField = {
        let passwordTextField = UITextField()
        passwordTextField.keyboardType = .default
        passwordTextField.placeholder = "пароль..."
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.backgroundColor = .white
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.returnKeyType = .done
        passwordTextField.textColor = .black
        passwordTextField.isSecureTextEntry = true
        return passwordTextField
    }()

    lazy var logInButton: UIButton = {
        let button = UIButton()
        button.setTitle("войти", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        let action = UIAction { _ in
            self.delegate?.didLoginButtonTapped(email: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "")
        }
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    var orLabel: UILabel = {
        let orLabel = UILabel()
        orLabel.text = "или"
        orLabel.textColor = .white
        orLabel.font = UIFont.systemFont(ofSize: 30)
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        return orLabel
    }()

    lazy var signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("регистрация", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        let action = UIAction { _ in self.delegate?.didTapRegister() }
        button.addAction(action, for: .touchUpInside)
        return button
    }()

    func resignResponders() {
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }



    override init(frame: CGRect) {
        super.init(frame: frame)
        loginTextField.delegate = self
        passwordTextField.delegate = self
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private func setupUI() {
        backgroundColor = .lightGray
        fieldStackView.addArrangedSubview(loginTextField)
        fieldStackView.addArrangedSubview(passwordTextField)
        fieldStackView.addArrangedSubview(logInButton)
        addSubview(fieldStackView)
        addSubview(orLabel)
        addSubview(signUpButton)

        NSLayoutConstraint.activate([

            fieldStackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            fieldStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            fieldStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),

            orLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            orLabel.topAnchor.constraint(equalTo: fieldStackView.bottomAnchor, constant: 40),

            signUpButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 40),
            signUpButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            signUpButton.widthAnchor.constraint(equalToConstant: 150),
            signUpButton.heightAnchor.constraint(equalToConstant: 50)

        ])


    }
}


extension AuthorizationView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            self.delegate?.didLoginButtonTapped(email: self.loginTextField.text ?? "", password: self.passwordTextField.text ?? "")
        }
        return true
    }
}
