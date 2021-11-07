//
//  AuthManager.swift
//  Tinder
//
//  Created by Gin Imor on 10/15/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import FirebaseAuth

let auth = AuthManager()

enum AuthError: Error {
  case notSignedIn
  case illegalUserInfo
  case noResponse
}

class AuthManager {
  
  var currentUser: FirebaseAuth.User? { Auth.auth().currentUser }
  var uid: String? { Auth.auth().currentUser?.uid }
  var hasCurrentUser: Bool { Auth.auth().currentUser != nil }
  
  func login(
    withEmail email: String,
    password: String,
    completion: @escaping (Error?) -> Void)
  {
    Auth.auth().signIn(withEmail: email, password: password) {
      dataResult, error in completion(error)
    }
  }
  
  func logout() {
    try? Auth.auth().signOut()
  }
  
  func createUser(
    withEmail email: String?,
    username: String?,
    password: String?,
    profileImageData: Data?,
    completion: @escaping (Error?) -> Void)
  {
    guard let email = email, let username = username, let password = password,
          let imageData = profileImageData else {
      completion(AuthError.illegalUserInfo)
      return
    }
    
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      guard error == nil else {
        print("create user error: \(String(describing: error))")
        completion(error)
        return
      }
      
      guard let uid = authResult?.user.uid else {
        completion(AuthError.noResponse)
        return
      }
      
      sto.putData(imageData, to: .profileImages) { imageUrl, error in
        guard error == nil else {
          completion(error)
          return
        }
        print("successfully get imageUrl", imageUrl ?? "")
        db.setUserInfo(
          uid: uid, name: username, imageUrl: imageUrl!, completion: completion)
      }
    }
  }
  
  func updateProfile(
    displayName: String?,
    imageURL: URL?,
    completion: @escaping (Error?) -> Void
  ) {
    guard let request = Auth.auth().currentUser?.createProfileChangeRequest() else {
      completion(AuthError.notSignedIn)
      return
    }
    request.displayName = displayName
    request.photoURL = imageURL
    request.commitChanges { (error) in
      completion(error)
    }
  }
  
}
