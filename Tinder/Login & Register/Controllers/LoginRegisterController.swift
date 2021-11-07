//
// LoginRegisterController.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD

protocol LoginRegisterControllerDelegate: AnyObject {
  func didFinishedLoggingIn()
}

class LoginRegisterController: UIViewController {
  
  static func loginRegisterButton(_ title: String) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.darkGray, for: .disabled)
    button.backgroundColor = .lightGray
    button.isEnabled = false
    button.layer.cornerRadius = 25
    return button
  }
  
  static func loginRegisterTextField(_ placeholder: String) -> PaddingTextField {
    let textField = PaddingTextField()
    textField.placeholder = placeholder
    textField.paddingX = 16
    textField.layer.cornerRadius = 25
    textField.backgroundColor = .white
    return textField
  }
  
  
  let emailTextField: PaddingTextField = {
    let textField = LoginRegisterController.loginRegisterTextField("Enter Email")
    textField.keyboardType = .emailAddress
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return textField
  }()
  
  let passwordTextField: PaddingTextField = {
    let textField = LoginRegisterController.loginRegisterTextField("Enter Password")
    textField.isSecureTextEntry = true
    return textField
  }()
  
  let navigationButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(.systemGray3, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  let gradientLayer = CAGradientLayer()
  
  weak var delegate: LoginRegisterControllerDelegate?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }

  func setupViews() {
    view.backgroundColor = .white
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    
    // at gradientLayer as the background color, need to add it as subview before other views
    gradientLayer.colors = [#colorLiteral(red: 0.9778892398, green: 0.3299795985, blue: 0.3270179033, alpha: 1).cgColor, #colorLiteral(red: 0.8706625104, green: 0.1032681242, blue: 0.4151168168, alpha: 1).cgColor]
    // at which point completely become the corresponding color
    gradientLayer.locations = [0.0, 1.0]
    let longer = 1.5 * max(view.bounds.width, view.bounds.height)
    let layerSize = CGSize(width: longer, height: longer)
    gradientLayer.frame = CGRect(origin: view.bounds.origin, size: layerSize)
    view.layer.addSublayer(gradientLayer)
    
    emailTextField.addTarget(self, action: #selector(editingDidChanged), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(editingDidChanged), for: .editingChanged)
    
    view.addSubview(navigationButton)
    NSLayoutConstraint.activate([
      navigationButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      navigationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
    ])
  }
  
  // forcely resign first responder if any in view's hierarchy
  @objc func handleTap() { view.endEditing(true) }
  
  @objc func editingDidChanged(_ textField: UITextField) {}

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
  
  func showHudForError(_ error: Error, message: String) {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = message
    hud.detailTextLabel.text = error.localizedDescription
    hud.show(in: view)
    hud.dismiss(afterDelay: 4.0)
  }
  
}
