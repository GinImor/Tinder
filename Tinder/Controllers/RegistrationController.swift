//
//  RegistrationController.swift
//  Tinder
//
//  Created by Gin Imor on 3/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class RegistrationController: UIViewController {

  var selectPhotoButtonWidth: NSLayoutConstraint?
  var selectPhotoButtonHeight: NSLayoutConstraint?
  
  var selecPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Select Photo", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
    button.backgroundColor = .white
    button.layer.cornerRadius = 16
    return button
  }()
  
  lazy var nameTextField: CustomTextField = {
    let textField = registrationTextField()
    textField.placeholder = "Enter Name"
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return textField
  }()
  
  lazy var emailTextField: CustomTextField = {
    let textField = registrationTextField()
    textField.placeholder = "Enter Email"
    textField.keyboardType = .emailAddress
    return textField
  }()
  
  lazy var passwordTextField: CustomTextField = {
    let textField = registrationTextField()
    textField.placeholder = "Enter Password"
//    textField.isSecureTextEntry = true
    return textField
  }()
  
  var registerButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Register", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = #colorLiteral(red: 0.7855796218, green: 0.09417917579, blue: 0.2886558473, alpha: 1)
    button.layer.cornerRadius = 25
    return button
  }()
  
  var outterStackView: UIStackView!
  
  let gradientLayer = CAGradientLayer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    addObservers()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    removeObservers()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    gradientLayer.frame = view.bounds
  }
  
  fileprivate func setupOutterStackViewAxis() {
    if traitCollection.verticalSizeClass == .compact {
      outterStackView.axis = .horizontal
      selectPhotoButtonHeight?.isActive = false
      outterStackView.layoutIfNeeded()
      selectPhotoButtonWidth?.isActive = true
    } else {
      outterStackView.axis = .vertical
      selectPhotoButtonWidth?.isActive = false
      outterStackView.layoutIfNeeded()
      selectPhotoButtonHeight?.isActive = true
    }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setupOutterStackViewAxis()
  }
  
  private func setupViews() {
    view.backgroundColor = .white
    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    
    gradientLayer.colors = [#colorLiteral(red: 0.9778892398, green: 0.3299795985, blue: 0.3270179033, alpha: 1).cgColor, #colorLiteral(red: 0.8706625104, green: 0.1032681242, blue: 0.4151168168, alpha: 1).cgColor]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.frame = view.bounds
    view.layer.addSublayer(gradientLayer)
    
    selectPhotoButtonWidth = selecPhotoButton.widthAnchor.constraint(equalToConstant: 300)
    selectPhotoButtonHeight = selecPhotoButton.heightAnchor.constraint(equalToConstant: 274)
    
    let innerArrangedViews = [nameTextField, emailTextField, passwordTextField, registerButton]
    let innerStackView = UIStackView.verticalStack(arrangedSubviews: innerArrangedViews)
    innerStackView.distribution = .fillEqually
    
    outterStackView = UIStackView.verticalStack(arrangedSubviews: [selecPhotoButton, innerStackView])
    outterStackView.centerToSuperviewSafeAreaLayoutGuide(superview: view)
    outterStackView.pinToSuperviewSafeAreaHorizontalEdges(defaultSpacing: 45)
    setupOutterStackViewAxis()
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
  private func addObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardShow),
      name: UIResponder.keyboardDidShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardHide),
      name: UIResponder.keyboardDidHideNotification,
      object: nil)
  }
  
  private func removeObservers() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func handleKeyboardShow(_ notification: Notification) {
    guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let frameEnd = value.cgRectValue
    let transitionY = frameEnd.minY - outterStackView.bounds.height/2 - outterStackView.center.y
    print("value", frameEnd, outterStackView.bounds.height/2, outterStackView.center.y)
    print("transitionY", transitionY)
    if transitionY < 0 {
      UIView.animate(withDuration: 0.5) {
        self.outterStackView.transform = CGAffineTransform(translationX: 0, y: transitionY)
      }
    }
  }
  
  @objc func handleKeyboardHide() {
    UIView.animate(withDuration: 0.5) {
        self.outterStackView.transform = .identity
    }
  }
  
  private func registrationTextField() -> CustomTextField {
    let textField = CustomTextField()
    textField.paddingX = 16
    textField.layer.cornerRadius = 25
    textField.backgroundColor = .white
    return textField
  }
}
