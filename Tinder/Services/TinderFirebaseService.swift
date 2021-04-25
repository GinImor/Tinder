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
  
  static var hasCurrentUser: Bool { currentUser != nil }
  
  static func pathString(_ child: String, subChildren: [String]) -> String{
    var pathString = child
    let subPathString = subChildren.joined(separator: "/")
    if subPathString != "" {
      pathString += "/\(subPathString)"
    }
    return pathString
  }
  
  static func pathForSTOChild(_ child: StorageChild, subChildren: String...) -> StorageReference {
    storage.child(pathString(child.rawValue, subChildren: subChildren))
  }
  
  static func configure() {
    FirebaseApp.configure()
  }
  
  static func login(
    withEmail email: String,
    password: String,
    completion: @escaping (Error?) -> Void)
  {
    auth.signIn(withEmail: email, password: password, completion: { dataResult, error in
      completion(error)
    })
  }
  
  static func logout() {
    try? auth.signOut()
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
        completion(NSError(domain: "", code: 1, userInfo: nil))
        return
    }
    auth.createUser(withEmail: email, password: password) { (authResult, error) in
      guard error == nil else {
        print("create user error: \(String(describing: error))")
        completion(error)
        return
      }
      guard let uid = authResult?.user.uid,
        let imageData = profileImageDataProvider() else {
          completion(NSError(domain: "", code: 1, userInfo: nil))
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
          completion(nil, NSError(domain: "", code: 1, userInfo: nil))
          return
        }
        completion(imageUrl, nil)
      })
    }
  }
  
  static func likeUserWithUid(_ uid: String, like: Bool, completion: @escaping (Bool, Error?) -> ()) {
    guard let currentUserUid = currentUser?.uid else {
      completion(false, NSError(domain: "", code: 3, userInfo: nil))
      return
    }
    let path = firestore.collection("Swipes").document(currentUserUid)
    path.getDocument { snapshot, error in
      guard let snapshot = snapshot, error == nil else {
        completion(false, error)
        return
      }
      let data = [uid: like]
      if snapshot.exists {
        path.updateData(data) { error in
          checkMatchUser(currentUid: currentUserUid, like: like, likingUid: uid, updatingLikeError: error,
            completion: completion)
        }
      } else {
        path.setData(data) { error in
          checkMatchUser(currentUid: currentUserUid, like: like, likingUid: uid, updatingLikeError: error,
            completion: completion)
        }
      }
    }
  }
  
  private static func checkMatchUser(currentUid: String, like: Bool, likingUid: String, updatingLikeError: Error?,
                                     completion: @escaping (Bool, Error?) -> ()) {
    guard updatingLikeError == nil else {
      completion(false, updatingLikeError)
      return
    }
    guard like else {
      completion(false, nil)
      return
    }
    let path = firestore.collection("Swipes").document(likingUid)
    path.getDocument { snapshot, error in
      guard error == nil else {
        completion(false, error)
        return
      }
      guard let dataBlock = snapshot?.data(), (dataBlock[currentUid] as? Bool) == true else {
        completion(false, nil)
        return
      }
      print("find a match!")
      completion(true, nil)
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
      storeCurrentUserToFirestore(user: newUser) { error in
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
      completion(NSError(domain: "", code: 1, userInfo: nil))
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
  
  static func fetchSwipedUsers(completion: @escaping ([String: Bool]?, Error?) -> Void) {
    guard let currentUid = currentUser?.uid else {
      completion(nil, NSError(domain: "", code: 3, userInfo: nil))
      return
    }
    let path = firestore.collection("Swipes").document(currentUid)
    path.getDocument { snapshot, error in
      guard error == nil else {
        completion(nil, error)
        return
      }
      completion(snapshot?.data() as? [String: Bool], nil)
    }
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
        if user.uid != currentUser?.uid {
          nextUserHandler(user)
        }
      })
      completion(nil)
    }
  }
  
  static func fetchCurrentUser(completion: @escaping (User?, Error?) -> Void) {
    guard let ref = currentUserFirestoreReference else {
      completion(nil, NSError(domain: "", code: 1, userInfo: nil))
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
      completion(NSError(domain: "", code: 1, userInfo: nil))
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
  
  static func fetchMatches(completion: @escaping ([MatchUser]?, Error?) -> Void) {
    guard let currentUserUid = currentUser?.uid else {
      completion(nil, NSError(domain: "", code: 3))
      return
    }
    matchesPathFor(currentUserUid).collection("Matches").getDocuments { querySnapshot, error in
      guard error == nil else {
        completion(nil, error)
        return
      }
      let matches = querySnapshot!.documents.map { documentSnapshot in
        MatchUser(userDic: documentSnapshot.data())
      }
      completion(matches, nil)
    }
  }
  
  static func storeMatches(_ userOne: CardModel, _ userTwo: CardModel, completion: @escaping (Error?) -> Void) {
    storeMatchesFor(userOne, matched: userTwo) { error in
      completion(error)
    }
    storeMatchesFor(userTwo, matched: userOne) { error in
      completion(error)
    }
  }
  
  private static func storeMatchesFor(_ user: CardModel, matched: CardModel, completion: @escaping (Error?) -> Void) {
    storeMetaDataToFirestore(
      path: matchesPathFor(user.uid, matched.uid),
      dataProvider: {
        var dataBlock: [String: Any] = [
          "name": matched.displayName,
          "uid": matched.uid,
          "timestamp": Timestamp(date: Date())
        ]
        if let profileImageUrl = matched.validImageUrls.first {
          dataBlock["profileImageUrl"] = profileImageUrl
        }
        return dataBlock
      }) { error in
      completion(error)
    }
  }
  
  private static func matchesPathFor(_ owner: String, _ matched: String = "") -> DocumentReference {
    let path = firestore.collection("MatchesInfo").document(owner)
    if matched == "" { return path }
    else { return path.collection("Matches").document(matched) }
  }
  
  static func fetchMessages(
    toUid: String,
    nextMessageHandler: @escaping (Message) -> Void,
    completion: @escaping (Error?) -> Void
  )-> ListenerRegistration? {
    guard let currentUid = currentUser?.uid else {
      completion(NSError(domain: "", code: 3, userInfo: nil))
      return nil
    }
    let query = messagePathFor(currentUid, toUid).order(by: "timestamp")
    let listener = query.addSnapshotListener { (querySnapshot, error) in
      guard error == nil else {
        completion(error)
        return
      }
      querySnapshot?.documentChanges.forEach {
        if $0.type == .added {
          nextMessageHandler(Message(dataDic: $0.document.data()))
        }
      }
      completion(nil)
    }
    return listener
  }
  
  static let messageDispatchGroup = DispatchGroup()
  
  static func storeMessage(_ message: String, toUid: String, completion: @escaping (Error?) -> Void) {
    guard let currentUid = currentUser?.uid else {
      completion(NSError(domain: "", code: 3, userInfo: nil))
      return
    }
    let dataBlock: [String: Any] = [
      "fromUid": currentUid,
      "text": message,
      "timestamp": Timestamp(date: Date()),
      "toUid": toUid
    ]
    storeMessage(dataBlock, for: currentUid, to: toUid, completion: completion)
    storeMessage(dataBlock, for: toUid, to: currentUid, completion: completion)
    messageDispatchGroup.notify(queue: .main) { completion(nil) }
  }
  
  private static func storeMessage(
    _ dataBlock: [String: Any],
    for fromUid: String,
    to toUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    messageDispatchGroup.enter()
    messagePathFor(fromUid, toUid).addDocument(data: dataBlock) { error in
      defer { messageDispatchGroup.leave() }
      if error != nil { completion(error) }
    }
  }
  
  private static func messagePathFor(_ owner: String, _ matched: String) -> CollectionReference {
    firestore.collection("MatchesInfo").document(owner).collection(matched)
  }
  
  static func fetchRecentMessages(
    nextMessageHandler: @escaping (RecentMessage) -> Void,
    completion: @escaping (Error?) -> Void
  ) -> ListenerRegistration? {
    guard let currentUid = currentUser?.uid else {
      completion(NSError(domain: "", code: 3))
      return nil
    }
    let listener = recentMessagePathFor(currentUid).addSnapshotListener { querySnapshot, error in
      guard error == nil else {
        completion(error)
        return
      }
      querySnapshot?.documentChanges.forEach {
        if $0.type == .added || $0.type == .modified {
          nextMessageHandler(RecentMessage(messageDic: $0.document.data()))
        }
      }
      completion(nil)
    }
    return listener
  }
  
  static func storeRecentMessage(
    _ text: String,
    currentUser: UserModel,
    chattingUser: UserModel,
    completion: @escaping (Error?) -> Void
  ) {
    storeRecentMessage(text, for: currentUser, to: chattingUser, completion: completion)
    storeRecentMessage(text, for: chattingUser, to: currentUser, completion: completion)
  }
  
  private static func storeRecentMessage(
    _ text: String,
    for currentUser: UserModel,
    to chattingUser: UserModel,
    completion: @escaping (Error?) -> Void
  ) {
    let dataBlock: [String: Any] = [
      "uid": chattingUser.uid,
      "profileImageUrl": chattingUser.profileImageUrl,
      "username": chattingUser.name,
      "text": text,
      "timestamp": Timestamp(date: Date())
    ]
    let path = recentMessagePathFor(currentUser.uid).document(chattingUser.uid)
    path.setData(dataBlock) { error in
      guard error == nil else {
        completion(error)
        return
      }
    }
  }
  
  private static func recentMessagePathFor(_ uid: String) -> CollectionReference {
    firestore.collection("MatchesInfo").document(uid).collection("RecentMessages")
  }
}
