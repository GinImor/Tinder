//
// LoginController.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD
import GILibrary

class LoginController: LoginRegisterController {
  
  let loginViewModel = LoginViewModel()
  
  let loginButton = loginRegisterButton("Log in")

  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewModel()
  }
  
  override func setupViews() {
    super.setupViews()
    
    vStack(emailTextField, passwordTextField, loginButton)
      .distributing(.fillEqually)
      .add(to: view).centering().hLining(edgeInsets: .init(45))

    navigationButton.setTitle("back to registration", for: .normal)
    navigationButton.addTarget(self, action: #selector(backToRegistration), for: .touchUpInside)
    
    loginButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
  }
  
  private func setupViewModel() {
    loginViewModel.bindableIsValid.bind { [unowned self] isValid in
      self.enableLoginRegisterButton(self.loginButton, enabling: isValid)
    }
    let progressHud = JGProgressHUD.new("Logging in")
    loginViewModel.bindableIsLoggingIn.bind { [unowned self] isLoggingIn in
      guard let isLoggingIn = isLoggingIn else { return }
      if isLoggingIn {
        progressHud.show(in: self.view)
      } else {
        progressHud.dismiss()
      }
    }
  }
  
  @objc func handleLogin() {
    handleTap()
    loginViewModel.performLoggingIn { [weak self] error in
     if let error = error {
       self?.showHudForError(error, message: "Login Error")
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
