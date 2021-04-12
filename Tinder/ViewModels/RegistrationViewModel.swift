//
//  RegistrationViewModel.swift
//  Tinder
//
//  Created by Gin Imor on 3/24/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class RegistrationViewModel {
  
  var bindableImage = Bindable<UIImage>()
  var bindableIsValid = Bindable<Bool>()
  var bindableIsRegistering = Bindable<Bool>()
  
  var textInput: (name: String?, email: String?, password: String?) = ("", "", "") {
    didSet { checkIfTextInputValid() }
  }
  
  func checkIfTextInputValid() {
    let isValid = textInput.0?.isEmpty == false &&
      textInput.1?.isEmpty == false &&
      textInput.2?.isEmpty == false
    
    bindableIsValid.value = isValid
  }
  
  func handleRegister(completion: @escaping (Error?) -> Void) {
    bindableIsRegistering.value = true
    TinderFirebaseService.createUser(
      withEmail: textInput.email,
      username: textInput.name,
      password: textInput.password,
      profileImageDataProvider: { [weak self] in
        self?.bindableImage.value?.jpegData(compressionQuality: 0.75)
    }) { [weak self] (error) in
      self?.bindableIsRegistering.value = false
      completion(error)
    }
  }
}
