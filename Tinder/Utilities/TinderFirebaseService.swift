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
  static var firestore: Firestore { Firestore.firestore() }
  
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
      let username = username,
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
      guard let uid = authResult?.user.uid,
        let imageData = profileImageDataProvider() else {
          completion(NSError())
          return
      }

      storeContentData(imageData, forChild: .profileImages) { imageUrl, error in
        guard error == nil else {
          completion(error)
          return
        }
        
        print("successfully get imageUrl", imageUrl ?? "")
        storeMetaDataToFirestore(
          path: firestore.collection("Users").document(uid),
          dataProvider: {
            ["imageUrl1": imageUrl!, "uid": uid, "name": username]
        }) { error in
          completion(error)
        }
        
      }
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
  
  static func storeMetaDataToFirestore(
    path: DocumentReference,
    dataProvider: () -> [String: Any]?,
    completion: @escaping (Error?) -> Void
  ) {
    guard let dataBlock = dataProvider() else {
       
      completion(NSError())
      return
    }
    path.setData(dataBlock) { (error) in
      completion(error)
    }
  }
  
  static func fetchUserMetaData(
    startingUid: String?,
    nextUserHandler: @escaping (User) -> Void,
    completion: @escaping (Error?) -> Void
  ) {
    let query = firestore.collection("Users")
      .order(by: "uid").start(after: [startingUid ?? ""]).limit(to: 2)
    query.getDocuments { (snapshot, error) in
      if let error = error {
        completion(error)
        return
      }
      
      snapshot?.documents.forEach({ (docSnapshot) in
        let user = User(userDic: docSnapshot.data())
        nextUserHandler(user)
      })
      completion(nil)
    }
  }
  
}
