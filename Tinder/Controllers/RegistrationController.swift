//
//  RegistrationController.swift
//  Tinder
//
//  Created by Gin Imor on 3/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD

class RegistrationController: LoginRegisterController {
  
  var registrationViewModel = RegistrationViewModel()
  
  var selectPhotoButtonWidth: NSLayoutConstraint?
  var selectPhotoButtonHeight: NSLayoutConstraint?
  
  lazy var selectPhotoButton: UIButton = {
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
  
  lazy var nameTextField: PaddingTextField = newNameTextField()
  lazy var emailTextField: PaddingTextField = newEmailTextField()
  lazy var passwordTextField: PaddingTextField = newPasswordTextField()
  
  lazy var registerButton: UIButton = {
    let button = self.newLoginRegisterButton()
    button.setTitle("Register", for: .normal)
    button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    return button
  }()
  
  lazy var goToLoginButton: UIButton = self.newNavigationButton()
  
  var outerStackView: UIStackView!
  
  var registerHud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Is Registering"
    return hud
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViewModel()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    addObservers()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeObservers()
  }
 
  fileprivate func setupOuterStackViewAxis() {
    if traitCollection.verticalSizeClass == .compact {
      outerStackView.axis = .horizontal
      selectPhotoButtonHeight?.isActive = false
      selectPhotoButtonWidth?.isActive = true
    } else {
      outerStackView.axis = .vertical
      selectPhotoButtonWidth?.isActive = false
      selectPhotoButtonHeight?.isActive = true
    }
  }
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setupOuterStackViewAxis()
  }
  
  override func setupViews() {
    super.setupViews()
    
    navigationController?.isNavigationBarHidden = true
    
    selectPhotoButtonWidth = selectPhotoButton.widthAnchor.constraint(equalToConstant: 300)
    selectPhotoButtonHeight = selectPhotoButton.heightAnchor.constraint(equalToConstant: 274)
    selectPhotoButtonWidth?.priority = UILayoutPriority(rawValue: 999)
    selectPhotoButtonHeight?.priority = UILayoutPriority(rawValue: 999)
    
    let innerArrangedViews = [nameTextField, emailTextField, passwordTextField, registerButton]
    let innerStackView = UIStackView.verticalStack(arrangedSubviews: innerArrangedViews)
    innerStackView.distribution = .fillEqually
    
    outerStackView = UIStackView.verticalStack(arrangedSubviews: [selectPhotoButton, innerStackView])
    outerStackView.centerToSuperviewSafeAreaLayoutGuide(superview: view)
    outerStackView.pinToSuperviewSafeAreaHorizontalEdges(defaultSpacing: 45)
    setupOuterStackViewAxis()
  
    goToLoginButton.setTitle("go to login", for: .normal)
    goToLoginButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
    
    // for test
    nameTextField.text = "Joey"
    emailTextField.text = "Apple@gmail.com"
    passwordTextField.text = "123456"
  }
  
  private func setupViewModel() {
    registrationViewModel.bindableImage.bind { [unowned self] (image) in
      self.selectPhotoButton.setTitle("", for: .normal)
      self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    registrationViewModel.bindableIsValid.bind { [unowned self] (isValid) in
      self.enableLoginRegisterButton(self.registerButton, enabling: isValid)
    }
    registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
      guard let isRegistering = isRegistering else {
        return
      }
      if isRegistering {
        self.registerHud.show(in: self.view)
      } else {
        self.registerHud.dismiss()
      }
    }
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
    guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
      return
    }
    let frameEnd = value.cgRectValue
    let transitionY = frameEnd.minY - outerStackView.bounds.height / 2 - outerStackView.center.y
    if transitionY < 0 {
      UIView.animate(withDuration: 0.5) {
        self.outerStackView.transform = CGAffineTransform(translationX: 0, y: transitionY)
      }
    }
  }
  
  @objc func handleKeyboardHide() {
    UIView.animate(withDuration: 0.5) {
      self.outerStackView.transform = .identity
    }
  }
  
  override func editingDidChanged(_ textField: UITextField) {
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
    registrationViewModel.handleRegister { [weak self] error in
      if let error = error {
        self?.showHUDWithError(error, message: "Registration Error")
        return
      }
      print("successfully create user")
      self?.delegate?.didFinishedLoggingIn()
    }
  }
  
  @objc func goToLogin() {
    let loginController = LoginController()
    loginController.delegate = delegate
    navigationController?.pushViewController(loginController, animated: true)
  }

}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    registrationViewModel.bindableImage.value = info[.originalImage] as? UIImage
    dismiss(animated: true)
  }
}
