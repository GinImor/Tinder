//
//  TinderFirebaseService.swift
//  Tinder
//
//  Created by Gin Imor on 3/24/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation
import Firebase

enum TinderFirebaseService {
  
  enum StorageChild: String {
    case postImages = "post_images"
    case profileImages = "profile_images"
  }
  
  static var auth: Auth { Auth.auth() }
  static var currentUser: Firebase.User? { auth.currentUser }
  static var storage: StorageReference { Storage.storage().reference() }
  
  static func pathString(_ child: String, subChilds: [String]) -> String{
    var pathString = child
    let subPathString = subChilds.joined(separator: "/")
    if subPathString != "" {
      pathString += "/\(subPathString)"
    }
    return pathString
  }
  
  static func pathForSTOChild(_ child: StorageChild, subChilds: String...) -> StorageReference {
    return storage.child(pathString(child.rawValue, subChilds: subChilds))
  }
  
  static func configure() {
    FirebaseApp.configure()
  }
  
  static func createUser(
    withEmail email: String?,
    username: String?,
    password: String?,
    profileImageDataProvider: @escaping () -> Data?,
    completion: @escaping (Error?) -> Void)
  {
    guard let email = email,
//      let username = username,
      let password = password else {
        completion(NSError())
        return
    }
    Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
      guard error == nil else {
        print("create user error: \(String(describing: error))")
        completion(error)
        return
      }
//      guard let uid = authResult?.user.uid,
//        let imageData = profileImageDataProvider() else {
//          completion(NSError())
//          return
//      }
//
//      storeContentData(imageData, forChild: .profileImages) { imageUrl, error in
//        guard error == nil else {
//          completion(error)
//          return
//        }
//        storeMetaData(
//          forChild: DatabaseChild.users(uid: uid),
//          metaDataProvider: {
//            return ["username": username, "profileImageUrl": imageUrl!]
//          },
//          completion: { error in
//            completion(error)
//          }
//        )
//      }
    }
  }
  
  static func storeContentData(
    _ contentData: Data,
    forChild child: StorageChild,
    completion: @escaping (String?, Error?) -> Void)
  {
    let fileName = NSUUID().uuidString
    let ref = pathForSTOChild(child, subChilds: fileName)
    ref.putData(contentData, metadata: nil) { (_, error) in
      if let error = error {
        print("put data error: \(error)")
        completion(nil, error)
      }
      ref.downloadURL(completion: { (url, error) in
        if let error = error {
          print("download url error: \(error)")
          completion(nil, error)
          return
        }
        
        guard let imageUrl = url?.absoluteString else {
          completion(nil, NSError())
          return
        }
        completion(imageUrl, nil)
      })
    }
  }
}
