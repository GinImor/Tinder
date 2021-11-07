//
//  FirestoreManager.swift
//  Tinder
//
//  Created by Gin Imor on 10/15/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import FirebaseFirestore

let db = FirestoreManager()

enum FirestoreError: Error {
  case uploadMatchErrors(Error?, Error?)
  case uploadRecentMessageErrors(Error?, Error?)
  case uploadMessageErrors(Error?, Error?)
}

protocol UserBasedObject: AnyObject {
  var user: User? {get set}
}

class FirestoreManager {
  
  var firestore: Firestore { Firestore.firestore() }
  
  weak var userBasedObject: UserBasedObject?
  
  var currUserRef: DocumentReference? {
    guard let uid = auth.uid else { return nil }
    return userRefFor(uid)
  }
  
  private func userRefFor(_ uid: String) -> DocumentReference {
    firestore.collection("Users").document(uid)
  }
  
  // set uid's user info
  func setUserInfo(
    uid: String,
    name: String,
    imageUrl: String,
    completion: @escaping (Error?) -> Void
  ) {
    let dataBlock: [String: Any] = [
      "uid": uid,
      "name": name,
      "imageUrl0": imageUrl,
      "minSeekingAge": 18,
      "maxSeekingAge": 100
    ]
    userRefFor(uid).setData(dataBlock, completion: completion)
  }
 
  // translate user to dataBlock, upload it
  func uploadUser(_ user: User, completion: @escaping (Error?) -> Void) {
    var dataBlock: [String: Any] = [
      "uid": user.uid,
      "name": user.name,
      "minSeekingAge": user.minSeekingAge,
      "maxSeekingAge": user.maxSeekingAge
    ]
    if let age = user.age { dataBlock["age"] = age }
    if let profession = user.profession { dataBlock["profession"] = profession }
    if let bio = user.bio { dataBlock["bio"] = bio }
    for i in 0..<user.imageUrls.count {
      guard let imageUrl = user.imageUrls[i] else { continue }
      dataBlock["imageUrl\(i)"] = imageUrl
    }
    
    userRefFor(user.uid).setData(dataBlock) { (error) in
      completion(error)
    }
  }
  
  func fetchCurrentUser(
    completion: @escaping (User?, Error?) -> Void
  ) {
    guard let ref = currUserRef else {
      completion(nil, AuthError.notSignedIn)
      return
    }
    ref.getDocument { (snapshot, error) in
      guard error == nil else {
        completion(nil, error)
        return
      }
      guard let userDic = snapshot?.data() else {
        completion(nil, AuthError.noResponse)
        return
      }
      let user = User(userDic: userDic)
      self.userBasedObject?.user = user
      completion(user, error)
    }
  }
  
  func fetchCurrentUserIfNecessary(
    fetchBeginingAction: (() -> Void)? = nil,
    completion: @escaping (User?, Error?) -> Void
  ) {
    if let user = userBasedObject?.user {
      completion(user, nil)
    } else {
      fetchBeginingAction?()
      fetchCurrentUser(completion: completion)
    }
  }
  
  func fetchSwipedUsers(
    completion: @escaping ([String: Bool]?, Error?) -> Void
  ) {
    guard let currUid = auth.uid else {
      completion(nil, AuthError.notSignedIn)
      return
    }
    let path = firestore.collection("Swipes").document(currUid)
    path.getDocument { snapshot, error in
      guard error == nil else {
        completion(nil, error)
        return
      }
      completion(snapshot?.data() as? [String: Bool], nil)
    }
  }
  
  // for pagination, after loggin in or saving the settings, reset to nil
  // so that fetching will start from the begining
  private var homeDocSnapshot: DocumentSnapshot?
  
  func nullifyHomeDocSnapshot() {
    homeDocSnapshot = nil
  }
  
  func fetchUsersBetweenAgeRange(
    minAge: Int,
    maxAge: Int,
    swipedUsers: [String: Bool],
    completion: @escaping ([User]?, Error?) -> Void
  ) {
    var query = firestore.collection("Users")
      .whereField("age", isGreaterThanOrEqualTo: minAge)
      .whereField("age", isLessThanOrEqualTo: maxAge)
      .limit(to: 10)
    if let snapshot = homeDocSnapshot {
      query = query.start(afterDocument: snapshot)
    }
    fetchUsers(
      query: query,
      swipedUsers: swipedUsers,
      completion: completion)
  }
  
  private func fetchUsers(
    query: Query,
    swipedUsers: [String: Bool],
    completion: @escaping ([User]?, Error?) -> Void
  ) {
    query.getDocuments { [weak self] (snapshot, error) in
      if let error = error {
        completion(nil, error)
        return
      }
      let users = snapshot?.documents.compactMap { (docSnapshot) -> User? in
        let user = User(userDic: docSnapshot.data())
        return user.uid != auth.uid && swipedUsers[user.uid] == nil ? user : nil
      }
      if let lastDocSnapshot = snapshot?.documents.last {
        self?.homeDocSnapshot = lastDocSnapshot
      }
      completion(users, nil)
    }
  }
  
  
  // set a like state on certain uid, then check if they are matched
  func setLikeStateForUid(
    _ currUid: String,
    on uid: String,
    to like: Bool,
    completion: @escaping (Error?) -> ()
  ) {
    let path = firestore.collection("Swipes").document(currUid)
    path.setData([uid: like], merge: true) { (error) in
      guard error == nil else { completion(error); return }
      guard like else { return }
      self.checkMatchUser(currentUid: currUid, anotherUid: uid, completion: completion)
    }
  }
  
  // check if another uid is liking current uid, if both like each other, upload the match states for both,
  // otherwise, complete with the error or just return
  private func checkMatchUser(
    currentUid: String,
    anotherUid: String,
    completion: @escaping (Error?) -> ()
  ) {
    let path = firestore.collection("Swipes").document(anotherUid)
    path.getDocument { snapshot, error in
      guard error == nil else { completion(error); return }
      guard let dataBlock = snapshot?.data(),
            (dataBlock[currentUid] as? Bool) == true else { return }
      print("find a match!")
      self.uploadMatch(currentUid, anotherUid, completion: completion)
    }
  }
  
  private func matchPathFor(_ owner: String, _ matched: String = "") -> DocumentReference {
     let path = firestore.collection("MatchesInfo").document(owner)
     if matched == "" { return path }
     else { return path.collection("Matches").document(matched) }
  }
  
  // upload the match state for both uid, if there is any error happen during the upload, complete
  // with FirestoreError.uploadMatchErrors
  func uploadMatch(
    _ currUid: String,
    _ matchedUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    let dispatchGroup = DispatchGroup()
    var errorOne, errorTwo: Error?
    dispatchGroup.enter()
    dispatchGroup.enter()
    uploadMatchFor(currUid, with: matchedUid) { error in
      errorOne = error
      dispatchGroup.leave()
    }
    uploadMatchFor(matchedUid, with: currUid) { error in
      errorTwo = error
      dispatchGroup.leave()
    }
    
    dispatchGroup.notify(queue: .main) {
      completion(errorOne == nil && errorTwo == nil ?
                  nil : FirestoreError.uploadMatchErrors(errorOne, errorTwo))
    }
  }

  // upload the match info for currUid about matchedUid
  private func uploadMatchFor(
    _ currUid: String,
    with matchedUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    let dataBlock: [String: Any] = [
      "uid": matchedUid,
      "timestamp": Timestamp(date: Date())
    ]
    matchPathFor(currUid, matchedUid).setData(dataBlock, completion: completion)
  }
  
  private var fetchingUids = [String]()
  
  private var lastMatchesTimestamp: Timestamp?
  
  func nullifyLastMatchesTimestamp() {
    lastMatchesTimestamp = nil
  }
  
  // only source of truth of match user info, data source of RecentMessageController,
  // MatchUsersController and ChatLogController
  var cachedMatchUserInfo = [String: (name: String?, imageUrl: String?)]()

  func matchUserInfo(for uid: String) -> (String?, String?) {
    var userInfo = cachedMatchUserInfo[uid]
    if userInfo == nil {
      userInfo = (nil, nil)
      cachedMatchUserInfo[uid] = userInfo
      selectedMatchUid = uid
      fetchUsers(in: [uid])
    }
    return userInfo!
  }
  
  var matchUserCell: [String: UserInfoCell<MatchUser>] = [:]

  func registerMatchUserCell(_ cell: UserInfoCell<MatchUser>) {
    matchUserCell[cell.uid] = cell
  }
  
  func unregisterMatchUserCell(_ cell: UserInfoCell<MatchUser>) {
    matchUserCell[cell.uid] = nil
  }
  
  func fetchMatches(
    completion: @escaping ([MatchUser]?, Error?) -> Void
  ) {
    guard let currUserUid = auth.uid else {
      completion(nil, AuthError.notSignedIn)
      return
    }
    var ref = matchPathFor(currUserUid).collection("Matches")
      .order(by: "timestamp", descending: true).limit(to: 20)
    if let timestamp = lastMatchesTimestamp {
      print("timestamp, ", timestamp)
      ref = ref.start(after: [timestamp])
    }
    ref.getDocuments { [weak self] (querySnapshot, error) in
      guard let self = self else { return }
      guard error == nil else {
        completion(nil, error)
        return
      }
      guard let documents = querySnapshot?.documents else {
        completion(nil, AuthError.noResponse)
        return
      }
      var matches = [MatchUser]()
      documents.forEach {
        let match = MatchUser(userDic: $0.data())
        matches.append(match)
        self.addToFetchingUidsIfNecessary(match.uid)
      }
      if !self.fetchingUids.isEmpty {
        self.fetchUsers(in: self.fetchingUids)
        self.fetchingUids = []
      }
      if let timestamp = documents.last?.data()["timestamp"] as? Timestamp {
        self.lastMatchesTimestamp = timestamp
      }
      completion(matches, nil)
    }
  }
  
  
  private let recentMessagesDispatchGroup = DispatchGroup()
  
  private func recentMessagePathFor(_ uid: String) -> CollectionReference {
    firestore.collection("MatchesInfo").document(uid).collection("RecentMessages")
  }
  
  func uploadRecentMessage(
    _ text: String,
    from fromUid: String,
    to toUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    var errorOne, errorTwo: Error?
    uploadRecentMessage(text, for: fromUid, to: toUid) { error in
      errorOne = error
    }
    uploadRecentMessage(text, for: toUid, to: fromUid) { error in
      errorTwo = error
    }
    recentMessagesDispatchGroup.notify(queue: .main) {
      if errorOne != nil || errorTwo != nil {
        completion(FirestoreError.uploadRecentMessageErrors(errorOne, errorTwo))
      } else {
        completion(nil)
      }
    }
  }
  
  private func uploadRecentMessage(
    _ text: String,
    for forUid: String,
    to toUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    recentMessagesDispatchGroup.enter()
    let dataBlock: [String: Any] = [
      "uid": toUid,
      "text": text,
      "timestamp": Timestamp(date: Date())
    ]
    let path = recentMessagePathFor(forUid).document(toUid)
    path.setData(dataBlock) { error in
      defer { self.recentMessagesDispatchGroup.leave() }
      guard error == nil else {
        completion(error)
        return
      }
    }
  }

  var recentMessageCell: [String: UserInfoCell<RecentMessage>] = [:]
  
  func registerRecentMessageCell(_ cell: UserInfoCell<RecentMessage>) {
    recentMessageCell[cell.uid] = cell
  }
  
  func unregisterRecentMessageCell(_ cell: UserInfoCell<RecentMessage>) {
    recentMessageCell[cell.uid] = nil
  }
  
  private var recentMessagesListener: ListenerRegistration?
  
  func removeRecentMessagesListener() {
    recentMessagesListener?.remove()
  }
  
  func listenToRecentMessages(
    completion: @escaping ([RecentMessage]?, Error?) -> Void
  ) {
    guard let currentUid = auth.uid else {
      completion(nil, AuthError.notSignedIn)
      return
    }
    // filter for latest recent messages
    let ref = recentMessagePathFor(currentUid).order(by: "timestamp").limit(toLast: 10)
    recentMessagesListener = ref.addSnapshotListener { [weak self] querySnapshot, error in
      guard let self = self else { return }
      guard error == nil else {
        completion(nil, error)
        return
      }
      // querySnapshot?.documents has the data set that satifies the query, every time
      // the data in the firestore change affect the data set, the completion get called,
      // the documentChanges is about the after changed relative the before changed of data set.
      // so instead of using LRUCache, can use the data set directly
      var recentMessages = [RecentMessage]()
      querySnapshot?.documentChanges.forEach {
        // every time the added or modified recent message will be taken to the head
        // and the last one get deleted, just like LRUCache
        if $0.type == .added || $0.type == .modified {
          let recentMessage = RecentMessage(messageDic: $0.document.data())
          recentMessages.append(recentMessage)
          self.addToFetchingUidsIfNecessary(recentMessage.uid)
        }
      }
      if !self.fetchingUids.isEmpty {
        self.fetchUsers(in: self.fetchingUids)
        self.fetchingUids = []
      }
      completion(recentMessages, nil)
    }
  }

  private func addToFetchingUidsIfNecessary(_ uid: String) {
    // not in the cache, denote that it doesn't exist, or it isn't being fetched
    if cachedMatchUserInfo[uid] == nil {
      fetchingUids.append(uid)
      // insert a placeholder to show that the uid is being fetched now
      cachedMatchUserInfo[uid] = (nil, nil)
      // if reach the max capacity of "in" method, go fetch it
      if fetchingUids.count == 10 {
        fetchUsers(in: fetchingUids)
        fetchingUids = []
      }
    }
  }
  
  // when the user info arrived, db know which one is the selected one
  var selectedMatchUid: String?
  
  private func fetchUsers(in uids: [String]) {
    // in collection "Users", get all documents with a "uid" field that
    // is any value in uids
    let ref = firestore.collection("Users").whereField("uid", in: uids)
    ref.getDocuments { [weak self] (querySnapshot, error) in
      guard let self = self else { return }
      if let error = error {
        print("error in fetching users ", error)
        return
      }
      querySnapshot?.documents.forEach {
        let data = $0.data()
        let uid = data["uid"] as? String ?? ""
        let name = data["name"] as? String
        let imageUrl = data["imageUrl0"] as? String
        // update the only source of truth
        self.cachedMatchUserInfo[uid] = (name, imageUrl)
        // update registered cell's content,
        // one uid will only be fetched one time, so don't need to nill it
        // when cell is going to be reused, will unregister the cell,
        // if can get the cell, means is still being used with the uid
        if let userInfoCell = self.recentMessageCell[uid] {
          userInfoCell.setUsername(name, imageUrl: imageUrl)
        }
        if let userInfoCell = self.matchUserCell[uid] {
          userInfoCell.setUsername(name, imageUrl: imageUrl)
        }
        // if uid has been selected, post notification uid been selected either
        // from MatchUsersController, RecentMessagesController, or MatchView in
        // HomeController, but they are going to the same destination:
        // ChatLogController's MessageNavBar
        if self.selectedMatchUid == uid {
          NotificationCenter.default.post(
            name: Notification.Name(uid),
            object: ["name": name, "imageUrl": imageUrl]
          )
        }
      }
    }
  }
  
  
  private let messageDispatchGroup = DispatchGroup()
  
  private func messagePathFor(_ owner: String, _ matched: String) -> CollectionReference {
    firestore.collection("MatchesInfo").document(owner).collection(matched)
  }
  
  func uploadMessage(
    _ message: String,
    from fromUid: String,
    to toUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    var errorOne, errorTwo: Error?
    let dataBlock: [String: Any] = [
      "fromUid": fromUid,
      "text": message,
      "timestamp": Timestamp(date: Date()),
      "toUid": toUid
    ]
    uploadMessageData(dataBlock, for: fromUid, to: toUid) { error in
      errorOne = error
    }
    uploadMessageData(dataBlock, for: toUid, to: fromUid) { error in
      errorTwo = error
    }
    messageDispatchGroup.notify(queue: .main) {
      if errorOne == nil && errorTwo == nil {
        completion(nil)
      } else {
        completion(FirestoreError.uploadMessageErrors(errorOne, errorTwo))
      }
    }
  }
  
  private func uploadMessageData(
    _ dataBlock: [String: Any],
    for forUid: String,
    to toUid: String,
    completion: @escaping (Error?) -> Void
  ) {
    messageDispatchGroup.enter()
    // it's a local write, so the listener will be invoked immediately,
    // but the write function completion will be called after the write completes
    messagePathFor(forUid, toUid).addDocument(data: dataBlock) { error in
      defer { self.messageDispatchGroup.leave() }
      if error != nil { completion(error) }
    }
  }
  
  private var messagesListener: ListenerRegistration?
  
  func removeMessagesListener() {
    messagesListener?.remove()
  }
  
  func listenToMessages(
    toUid: String,
    nextMessageHandler: @escaping (Message) -> Void,
    completion: @escaping (Error?) -> Void
  ) {
    guard let currentUid = auth.uid else {
      completion(AuthError.notSignedIn)
      return
    }
    let query = messagePathFor(currentUid, toUid).order(by: "timestamp")
    messagesListener = query.addSnapshotListener { (querySnapshot, error) in
      guard error == nil else {
        completion(error)
        return
      }
      
      querySnapshot?.documentChanges.forEach {
        if $0.type == .added {
          // either from the server or from local write, use $0.document.metadata.hasPendingWrites
          // to tell which one it is,
          nextMessageHandler(Message(dataDic: $0.document.data()))
        }
      }
      completion(nil)
    }
  }
  
}
