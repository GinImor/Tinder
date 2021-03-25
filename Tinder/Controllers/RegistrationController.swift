//
//  RegistrationController.swift
//  Tinder
//
//  Created by Gin Imor on 3/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD

class RegistrationController: UIViewController {

  var registrationViewModel = RegistrationViewModel()
  
  var selectPhotoButtonWidth: NSLayoutConstraint?
  var selectPhotoButtonHeight: NSLayoutConstraint?
  
  lazy var selecPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Select Photo", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
    button.backgroundColor = .white
    button.layer.cornerRadius = 16
    button.imageView?.contentMode = .scaleAspectFill
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
    return button
  }()
  
  lazy var nameTextField: PaddingTextField = {
    let textField = registrationTextField()
    textField.placeholder = "Enter Name"
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    return textField
  }()
  
  lazy var emailTextField: PaddingTextField = {
    let textField = registrationTextField()
    textField.placeholder = "Enter Email"
    textField.keyboardType = .emailAddress
    return textField
  }()
  
  lazy var passwordTextField: PaddingTextField = {
    let textField = registrationTextField()
    textField.placeholder = "Enter Password"
//    textField.isSecureTextEntry = true
    return textField
  }()
  
  var registerButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Register", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.setTitleColor(.darkGray, for: .disabled)
    button.backgroundColor = .lightGray
    button.isEnabled = false
    button.layer.cornerRadius = 25
    button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    return button
  }()
  
  var outterStackView: UIStackView!
  
  let gradientLayer = CAGradientLayer()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    addObservers()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
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
      selectPhotoButtonWidth?.isActive = true
    } else {
      outterStackView.axis = .vertical
      selectPhotoButtonWidth?.isActive = false
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
    selectPhotoButtonWidth?.priority = UILayoutPriority(rawValue: 999)
    selectPhotoButtonHeight?.priority = UILayoutPriority(rawValue: 999)
    
    let innerArrangedViews = [nameTextField, emailTextField, passwordTextField, registerButton]
    let innerStackView = UIStackView.verticalStack(arrangedSubviews: innerArrangedViews)
    innerStackView.distribution = .fillEqually
    
    outterStackView = UIStackView.verticalStack(arrangedSubviews: [selecPhotoButton, innerStackView])
    outterStackView.centerToSuperviewSafeAreaLayoutGuide(superview: view)
    outterStackView.pinToSuperviewSafeAreaHorizontalEdges(defaultSpacing: 45)
    setupOutterStackViewAxis()
    
    // for test
    nameTextField.text = "Joey"
    emailTextField.text = "Apple@gmail.com"
    passwordTextField.text = "123456"
  }
  
  private func setupViewModel() {
    registrationViewModel.bindableImage.bind { [unowned self] (image) in
      self.selecPhotoButton.setTitle("", for: .normal)
      self.selecPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    registrationViewModel.bindableIsValid.bind { [unowned self] (isValid) in
      guard let isValid = isValid else { return }
      if isValid {
        self.registerButton.isEnabled = true
        self.registerButton.backgroundColor = #colorLiteral(red: 0.7855796218, green: 0.09417917579, blue: 0.2886558473, alpha: 1)
      } else {
        self.registerButton.isEnabled = false
        self.registerButton.backgroundColor = .lightGray
      }
    }
    registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
      guard let isRegistering = isRegistering else { return }
      if isRegistering {
        self.registerHud.show(in: self.view)
      } else {
        self.registerHud.dismiss()
      }
    }
  }
  
  var registerHud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Is Registering"
    return hud
  }()
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
  private func addObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardShow),
      name: UIResponder.keyboardWillShowNotification,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleKeyboardHide),
      name: UIResponder.keyboardWillHideNotification,
      object: nil)
  }
  
  private func removeObservers() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func handleKeyboardShow(_ notification: Notification) {
    guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
    let frameEnd = value.cgRectValue
    let transitionY = frameEnd.minY - outterStackView.bounds.height/2 - outterStackView.center.y
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
  
  @objc func editingDidChanged(_ textField: UITextField) {
    if textField === nameTextField {
      registrationViewModel.textInput.name = textField.text
    } else if textField === emailTextField {
      registrationViewModel.textInput.email = textField.text
    } else {
      registrationViewModel.textInput.password = textField.text
    }
  }
  
  @objc func handleSelectPhoto() {
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
  
  @objc func handleRegister() {
    handleTap()
    registrationViewModel.handleRegister { error in
      if let error = error {
        self.showHUDWithError(error)
        return
      }
      print("successfully create user")
    }
  }
  
  private func showHUDWithError(_ error: Error) {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Registration Error"
    hud.detailTextLabel.text = error.localizedDescription
    hud.show(in: view)
    hud.dismiss(afterDelay: 4.0)
  }
  
  private func registrationTextField() -> PaddingTextField {
    let textField = PaddingTextField()
    textField.paddingX = 16
    textField.layer.cornerRadius = 25
    textField.backgroundColor = .white
    textField.addTarget(self, action: #selector(editingDidChanged), for: .editingChanged)
    return textField
  }
}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    registrationViewModel.bindableImage.value = info[.originalImage] as? UIImage
    dismiss(animated: true)
  }
}
