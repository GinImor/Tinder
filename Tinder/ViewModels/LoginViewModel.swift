//
// LoginViewModel.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

class LoginViewModel {
  
  var bindableIsValid = Bindable<Bool>()
  var bindableIsLoggingIn = Bindable<Bool>()
  
  var email: String? { didSet {checkIfTextInputValid()} }
  var password: String? { didSet {checkIfTextInputValid()} }
  
  private func checkIfTextInputValid() {
    guard let email = email, let password = password else { return }
    let isValid = !email.isEmpty && !password.isEmpty
    bindableIsValid.value = isValid
  }
  
  func performLoggingIn(completion: @escaping (Error?) -> Void) {
    guard let email = email, let password = password else { return }
    bindableIsLoggingIn.value = true
    TinderFirebaseService.login(withEmail: email, password: password) { [weak self] error in
      self?.bindableIsLoggingIn.value = false
      completion(error)
    }
  }
}
