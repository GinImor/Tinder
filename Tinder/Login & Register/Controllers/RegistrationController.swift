//
//  RegistrationController.swift
//  Tinder
//
//  Created by Gin Imor on 3/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD
import GILibrary

class RegistrationController: LoginRegisterController {
  
  var registrationViewModel = RegistrationViewModel()
  
  var selectPhotoButtonWidth: NSLayoutConstraint?
  var selectPhotoButtonHeight: NSLayoutConstraint?
  
  let selectPhotoButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Select Photo", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
    button.backgroundColor = .white
    button.layer.cornerRadius = 16
    button.imageView?.contentMode = .scaleAspectFill
    button.clipsToBounds = true
    return button
  }()
  
  let nameTextField = loginRegisterTextField("Enter Name")
  let registerButton = loginRegisterButton("Register")
  
  var formStack: UIStackView!
  
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

  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    setupformStackAxis()
  }
  
  fileprivate func setupformStackAxis() {
    if traitCollection.verticalSizeClass == .compact {
      formStack.axis = .horizontal
      selectPhotoButtonHeight?.isActive = false
      selectPhotoButtonWidth?.isActive = true
    } else {
      formStack.axis = .vertical
      selectPhotoButtonWidth?.isActive = false
      selectPhotoButtonHeight?.isActive = true
    }
  }
  
  override func setupViews() {
    super.setupViews()
    
    navigationController?.isNavigationBarHidden = true
    
    selectPhotoButtonWidth = selectPhotoButton.widthAnchor.constraint(equalToConstant: 300)
    selectPhotoButtonHeight = selectPhotoButton.heightAnchor.constraint(equalToConstant: 274)
    selectPhotoButtonWidth?.priority = UILayoutPriority(rawValue: 999)
    selectPhotoButtonHeight?.priority = UILayoutPriority(rawValue: 999)
    
    let innerArrangedViews = [nameTextField, emailTextField, passwordTextField, registerButton]
    
    formStack = vStack(
      selectPhotoButton,
      vStack(innerArrangedViews).distributing(.fillEqually)
    )
    .add(to: view).centering().hLining(edgeInsets: .init(45))
    
    setupformStackAxis()
    
    selectPhotoButton.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
    nameTextField.addTarget(self, action: #selector(editingDidChanged), for: .editingChanged)
    registerButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
    
    navigationButton.setTitle("go to login", for: .normal)
    navigationButton.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
  }
  
  private func setupViewModel() {
    registrationViewModel.bindableImage.bind { [unowned self] (image) in
      self.selectPhotoButton.setTitle("", for: .normal)
      self.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    registrationViewModel.bindableIsValid.bind { [unowned self] (isValid) in
      self.enableLoginRegisterButton(self.registerButton, enabling: isValid)
    }
    let progressHud = JGProgressHUD.new("Regestering")
    registrationViewModel.bindableIsRegistering.bind { [unowned self] (isRegistering) in
      guard let isRegistering = isRegistering else {
        return
      }
      if isRegistering {
        progressHud.show(in: self.view)
      } else {
        progressHud.dismiss()
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
    // center, bounds, transform determine frame, so change transform change frame, doesn't change
    // center and bounds, but once convert passwordTextField's center from its superview to nil
    // the converted center changed, center just don't change in its superview coordinate system
    // but cause the superview itself move in the nil coordinate system, so the passwordTextField move.
    // the whole process is top down, in nil coordinate, get the relevent view's frame, subtract its bounds.origin
    // find the next relevent view's frame, repeat the process till the end.
    let lastTextFieldMaxY = passwordTextField.superview!.convert(passwordTextField.frame, to: nil).maxY
    let transitionY = frameEnd.minY - 10 - lastTextFieldMaxY
    UIView.animate(withDuration: 0.5) {
      let transform = self.formStack.transform.translatedBy(x: 0, y: transitionY)
      self.formStack.transform = transform
    }
  }
  
  @objc func handleKeyboardHide() {
    UIView.animate(withDuration: 0.5) {
      self.formStack.transform = .identity
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
        self?.showHudForError(error, message: "Registration Error")
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
    registrationViewModel.profileImage = info[.originalImage] as? UIImage
    dismiss(animated: true)
  }
}
