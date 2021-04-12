//
// LoginController.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD

class LoginController: LoginRegisterController {
  
  let loginViewModel = LoginViewModel()
  
  private lazy var emailTextField: PaddingTextField = newEmailTextField()
  private lazy var passwordTextField: PaddingTextField = newPasswordTextField()
  private lazy var loginButton: UIButton = {
    let button = newLoginRegisterButton()
    button.setTitle("Log in", for: .normal)
    button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
    return button
  }()
  private lazy var backToRegistrationButton: UIButton = newNavigationButton()
  
  private var loginHud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Logging in"
    return hud
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewModel()
  }
  
  override func setupViews() {
    super.setupViews()
    
    let stackView = UIStackView.verticalStack(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
    stackView.distribution = .fillEqually
    stackView.centerToSuperviewSafeAreaLayoutGuide(superview: view)
    stackView.pinToSuperviewSafeAreaHorizontalEdges(defaultSpacing: 45)
    
    backToRegistrationButton.setTitle("back to registration", for: .normal)
    backToRegistrationButton.addTarget(self, action: #selector(backToRegistration), for: .touchUpInside)
  }
  
  private func setupViewModel() {
    loginViewModel.bindableIsValid.bind { [unowned self] isValid in
      self.enableLoginRegisterButton(self.loginButton, enabling: isValid)
    }
    loginViewModel.bindableIsLoggingIn.bind { [unowned self] isLoggingIn in
      guard let isLoggingIn = isLoggingIn else { return }
      if isLoggingIn {
        self.loginHud.show(in: self.view)
      } else {
        self.loginHud.dismiss()
      }
    }
  }
  
  @objc func handleLogin() {
    handleTap()
    loginViewModel.performLoggingIn { [weak self] error in
     if let error = error {
       self?.showHUDWithError(error, message: "Login Error")
       return
     }
      print("successfully login")
      self?.delegate?.didFinishedLoggingIn()
    }
  }
  
  @objc func backToRegistration() {
    navigationController?.popViewController(animated: true)
  }
  
  override func editingDidChanged(_ textField: UITextField) {
    if textField === emailTextField {
      loginViewModel.email = textField.text
    } else if textField === passwordTextField {
      loginViewModel.password = textField.text
    }
  }
}
