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
  
  private static var dispatchGroup = DispatchGroup()
  
  static func pathString(_ child: String, subChildren: [String]) -> String{
    var pathString = child
    let subPathString = subChildren.joined(separator: "/")
    if subPathString != "" {
      pathString += "/\(subPathString)"
    }
    return pathString
  }
  
  static func pathForSTOChild(_ child: StorageChild, subChildren: String...) -> StorageReference {
    return storage.child(pathString(child.rawValue, subChildren: subChildren))
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
    let ref = pathForSTOChild(child, subChildren: fileName)
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
  
  static func storeImages(
    imagesDataProvider: () -> [Data?],
    for user: User,
    initialImageUrls: [String?],
    completion: @escaping (User?, Error?) -> Void) {
    let imagesData = imagesDataProvider()
    var imageUrls = initialImageUrls
    for i in 0..<imagesData.count {
      guard let imageData = imagesData[i] else { continue }
      dispatchGroup.enter()
      storeContentData(imageData, forChild: .profileImages
      ) { imageUrl, error in
        defer { dispatchGroup.leave() }
        imageUrls[i] = imageUrl
        print("successfully upload image\(i)")
      }
    }
    dispatchGroup.notify(queue: .main) {
      print("successfully update image urls")
      var newUser = user
      newUser.imageUrls = imageUrls
      storeCurrentUserToFirestore(user: newUser
      ) { error in
        completion(newUser, error)
      }
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
    fetchUsers(query: query, nextUserHandler: nextUserHandler, completion: completion)
  }
  
  static func fetchUsersBetweenAgeRange(
    minAge: Int,
    maxAge: Int,
    nextUserHandler: @escaping (User) -> Void,
    completion: @escaping (Error?) -> Void) {
    let query = firestore.collection("Users")
      .whereField("age", isGreaterThanOrEqualTo: minAge)
      .whereField("age", isLessThanOrEqualTo: maxAge)
    fetchUsers(query: query, nextUserHandler: nextUserHandler, completion: completion)
  }
  
  static var currentUserFirestoreReference: DocumentReference? {
    guard let uid = currentUser?.uid else { return nil }
    return firestore.collection("Users").document("\(uid)")
  }
  
  private static func fetchUsers(
    query: Query,
    nextUserHandler: @escaping (User) -> Void,
    completion: @escaping (Error?) -> Void) {
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
  
  static func fetchCurrentUser(completion: @escaping (User?, Error?) -> Void) {
    guard let ref = currentUserFirestoreReference else {
      completion(nil, NSError())
      return
    }
    ref.getDocument { (snapshot, error) in
      guard let userDic = snapshot?.data() else {
        completion(nil, error)
        return
      }
      let user = User(userDic: userDic)
      completion(user, error)
    }
  }
  
  
  static func storeCurrentUserToFirestore(
    user: User,
    completion: @escaping (Error?) -> Void) {
    guard let ref = currentUserFirestoreReference else {
      completion(NSError())
      return
    }
    var userData: [String: Any] = [
      "uid": user.uid,
      "name": user.name,
      "minSeekingAge": user.minSeekingAge,
      "maxSeekingAge": user.maxSeekingAge
    ]
    if let age = user.age { userData["age"] = age }
    if let profession = user.profession { userData["profession"] = profession }
    for i in 0..<user.imageUrls.count {
      guard let imageUrl = user.imageUrls[i] else { continue }
      userData["imageUrl\(i)"] = imageUrl
    }
    
    ref.setData(userData) { (error) in
      completion(error)
    }
  }
}
