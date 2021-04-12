//
// LoginRegisterController.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol LoginRegisterControllerDelegate: class {
  func didFinishedLoggingIn()
}

class LoginRegisterController: UIViewController {
  
  let gradientLayer = CAGradientLayer()
  
  weak var delegate: LoginRegisterControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    gradientLayer.frame = view.bounds
  }
  
  func setupViews() {
    view.backgroundColor = .white
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    
    gradientLayer.colors = [#colorLiteral(red: 0.9778892398, green: 0.3299795985, blue: 0.3270179033, alpha: 1).cgColor, #colorLiteral(red: 0.8706625104, green: 0.1032681242, blue: 0.4151168168, alpha: 1).cgColor]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.frame = view.bounds
    view.layer.addSublayer(gradientLayer)
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
  func newEmailTextField() -> PaddingTextField {
    let textField = loginRegisterTextField()
    textField.placeholder = "Enter Email"
    textField.keyboardType = .emailAddress
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return textField
  }
  
  func newPasswordTextField() -> PaddingTextField {
    let textField = loginRegisterTextField()
    textField.placeholder = "Enter Password"
    textField.isSecureTextEntry = true
    return textField
  }
  
  func newNameTextField() -> PaddingTextField {
    let textField = loginRegisterTextField()
    textField.placeholder = "Enter Name"
    return textField
  }
  
  func newLoginRegisterButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.darkGray, for: .disabled)
    button.backgroundColor = .lightGray
    button.isEnabled = false
    button.layer.cornerRadius = 25
    return button
  }
  
  func newNavigationButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(.white, for: .normal)
    button.disableTAMIC()
    view.addSubview(button)
    NSLayoutConstraint.activate([
      button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    return button
  }
  
  func enableLoginRegisterButton(_ button: UIButton, enabling: Bool?) {
    guard let enabling = enabling else { return }
    if enabling {
      button.isEnabled = true
      button.backgroundColor = #colorLiteral(red: 0.7855796218, green: 0.09417917579, blue: 0.2886558473, alpha: 1)
    } else {
      button.isEnabled = false
      button.backgroundColor = .lightGray
    }
  }
  
  func showHUDWithError(_ error: Error, message: String) {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = message
    hud.detailTextLabel.text = error.localizedDescription
    hud.show(in: view)
    hud.dismiss(afterDelay: 4.0)
  }
  
  private func loginRegisterTextField() -> PaddingTextField {
    let textField = PaddingTextField()
    textField.paddingX = 16
    textField.layer.cornerRadius = 25
    textField.backgroundColor = .white
    textField.addTarget(self, action: #selector(editingDidChanged), for: .editingChanged)
    return textField
  }
  
  @objc func editingDidChanged(_ textField: UITextField) {}
}
