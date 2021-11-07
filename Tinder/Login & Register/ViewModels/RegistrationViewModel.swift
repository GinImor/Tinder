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
    didSet { checkIfInputValid() }
  }
  
  var profileImage: UIImage? {
    didSet {
      bindableImage.value = profileImage
      checkIfInputValid()
    }
  }
  
  func checkIfInputValid() {
    bindableIsValid.value =
      textInput.0?.isEmpty == false &&
      textInput.1?.isEmpty == false &&
      textInput.2?.isEmpty == false &&
      // cause is Tinder, need at least one photo
      bindableImage.value != nil
  }
  
  func handleRegister(completion: @escaping (Error?) -> Void) {
    bindableIsRegistering.value = true
    auth.createUser(
      withEmail: textInput.email,
      username: textInput.name,
      password: textInput.password,
      profileImageData: bindableImage.value?.scaledJpegDataForUpload
    ) { [unowned self] (error) in
      self.bindableIsRegistering.value = false
      completion(error)
    }
  }
}
