//
//  DatabaseManager.swift
//  Tinder
//
//  Created by Gin Imor on 11/27/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Firebase
import FirebaseDatabase
import CoreData

unowned let db = DatabaseManager.shared

enum DatabaseError: Error {
  case noResponse
  case cantGetAutoId
  case fetchUserError(Error?, Error?)
}

protocol UserBasedObject: AnyObject {
  var user: User? {get set}
}


class DatabaseManager {
  
  static var shared = DatabaseManager()
  
  private init() {}
  
  private var database: Database { Database.database() }
  private var databaseRef: DatabaseReference { Database.database().reference() }
  
  weak var userBasedObject: UserBasedObject?
  
  var isConnected = false
  
  func monitorConnection() {
    let connectedRef = databaseRef.child(".info/connected")
    connectedRef.observe(.value) { [weak self] snapshot in
      let isConnected = snapshot.value as? Bool ?? false
      self?.isConnected = isConnected
    }
  }
  
  
  // set uid's user info
  func setUserInfo(
    uid: String,
    name: String,
    imageUrl: String,
    completion: @escaping (Error?) -> Void
  ) {
    let infoDataBlock: [String: Any] = [
      "name": name,
      "imageUrl0": imageUrl
    ]
    let prefDataBlock: [String: Any] = [
      "minSeekingAge": 18,
      "maxSeekingAge": 35
    ]
    let childUpdates = [
      "/userInfos/\(uid)": infoDataBlock,
      "/userPreferences/\(uid)": prefDataBlock
    ]
    databaseRef.updateChildValues(childUpdates) { error, ref in
      completion(error)
    }
  }
  
  func updateUser(_ user: User, competion: @escaping (Error?) -> Void ) {
    let info = user.info
    let preference = user.preference
    
    var infoDataBlock: [String: Any?] = [
      "name": info.name,
      "age": info.age,
      "profession": info.profession,
      "bio": info.bio
    ]
    for i in 0..<info.imageUrls.count {
      guard let imageUrl = info.imageUrls[i] else { continue }
      infoDataBlock["imageUrl\(i)"] = imageUrl
    }
    
    let prefDataBlock: [String: Any?] = [
      "minSeekingAge": preference.minSeekingAge,
      "maxSeekingAge": preference.maxSeekingAge
    ]
    
    let childUpdates = ["/userInfos/\(info.uid)": infoDataBlock,
                        "/userPreferences/\(info.uid)": prefDataBlock]
    
    databaseRef.updateChildValues(childUpdates) { error, ref in competion(error) }
  }
  
  func fetchCurrentUser(
    completion: @escaping (User?, Error?) -> Void
  ) {
    guard let currUid = auth.uid else {
      completion(nil, AuthError.notSignedIn)
      return
    }
    let dispatchGroup = DispatchGroup()
    let infoRef = databaseRef.child("userInfos/\(currUid)")
    let prefRef = databaseRef.child("userPreferences/\(currUid)")
    var infoError, prefError: Error?
    var infoSnapshot, prefSnapshot: DataSnapshot?
    
    dispatchGroup.enter()
    infoRef.observeSingleEvent(of: .value) { snapshot in
      infoSnapshot = snapshot
      dispatchGroup.leave()
    } withCancel: { error in
      infoError = error
      dispatchGroup.leave()
    }
    dispatchGroup.enter()
    prefRef.observeSingleEvent(of: .value) { snapshot in
      prefSnapshot = snapshot
      dispatchGroup.leave()
    } withCancel: { error in
      prefError = error
      dispatchGroup.leave()
    }

    dispatchGroup.notify(queue: .main) {
      guard infoError == nil && prefError == nil else {
        completion(nil, DatabaseError.fetchUserError(infoError, prefError))
        return
      }
      guard let infoDic = infoSnapshot?.value as? [String: Any],
            let prefDic = prefSnapshot?.value as? [String: Any] else {
        completion(nil, DatabaseError.noResponse)
        return
      }
      let user = User(key: currUid, infoDic: infoDic, prefDic: prefDic)
      self.userBasedObject?.user = user
      completion(user, nil)
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
    let ref = databaseRef.child("swipes/\(currUid)")
    ref.getData { error, snapshot in
      guard error == nil else {
        completion(nil, error)
        return
      }
      completion(snapshot.value as? [String: Bool], nil)
    }
  }
  
  var homePaginationKey: String?
  
  func nullifyHomePaginationKey() {
    homePaginationKey = nil
  }
  
  func fetchUsersBetweenAgeRange(
    minAge: Int,
    maxAge: Int,
    swipedUsers: [String: Bool],
    completion: @escaping ([User.Info]?, Error?) -> Void
  ) {
    var query = databaseRef.child("userInfos")
      .queryOrderedByKey().queryLimited(toFirst: 5)
    if homePaginationKey != nil {
      query = query.queryStarting(afterValue: homePaginationKey)
    }
    query.getData { [weak self] error, snapshot in
      guard error == nil else {
        DispatchQueue.main.async { completion(nil, error) }
        return
      }
      let usersInfos = snapshot.children.allObjects.compactMap {
        (childSnapshot) -> User.Info? in
        guard let childSnapshot = childSnapshot as? DataSnapshot,
              let infoDic = childSnapshot.value as? [String: Any] else {
          return nil
        }
        let userInfo = User.Info(key: childSnapshot.key, dic: infoDic)
        return swipedUsers[userInfo.uid] == nil &&
        userInfo.uid != auth.uid &&
        userInfo.age != nil &&
        userInfo.age! >= minAge &&
        userInfo.age! <= maxAge
        ? userInfo : nil
      }
      if let lastKey = (snapshot.children.allObjects.last as? DataSnapshot)?.key {
        self?.homePaginationKey = lastKey
      }
      DispatchQueue.main.async { completion(usersInfos, nil) }
    }
  }
  
  // set a like state on certain uid, check if they are matched
  func setLikeStateForUid(
    _ currUid: String,
    on uid: String,
    to like: Bool,
    completion: @escaping (String?, Error?) -> ()
  ) {
    let ref = databaseRef.child("swipes/\(currUid)/\(uid)")
    if like {
      let ref2 = databaseRef.child("swipes/\(uid)/\(currUid)")
      ref2.getData { [weak self] error, snapshot in
        guard error == nil else {
          completion(nil, error)
          return
        }
        guard let likeBack = snapshot.value as? Bool, likeBack else {
          ref.setValue(like) { error, _ in completion(nil, error) }
          return
        }
        // find a match
        guard let chatRoomId = self?.databaseRef.child("messages").childByAutoId().key else {
          completion(nil, DatabaseError.cantGetAutoId)
          return
        }
        let matchDate = Date().timeIntervalSince1970
        let chatRoomInfo: [String: Any] = [
          "matchDate": matchDate,
          "chatRoomId": chatRoomId
        ]
        let childUpdates: [String: Any] = [
          "/swipes/\(currUid)/\(uid)": true,
          "/matches/\(currUid)/\(uid)": chatRoomInfo,
          "/matches/\(uid)/\(currUid)": chatRoomInfo,
        ]
        self?.databaseRef.updateChildValues(childUpdates) { error, _ in
          completion(chatRoomId, error)
        }
      }
    } else {
      ref.setValue(like) { error, _ in completion(nil, error) }
    }
  }
  
  func chatRoomIdForUid(
    _ currUid: String,
    matchUid: String,
    completion: @escaping (String?, Error?) -> Void
  ) {
    let ref = databaseRef.child("matches/\(currUid)/\(matchUid)")
    ref.getData { error, snapshot in
      DispatchQueue.main.async {
        guard error == nil else {
          completion(nil, error)
          return
        }
        guard let chatRoomId = snapshot.value as? String else {
          completion(nil, DatabaseError.noResponse)
          return
        }
        completion(chatRoomId, nil)
      }
    }
  }
  
  var matchUserCell: [String: UserInfoCell] = [:]

  func registerMatchUserCell(_ cell: UserInfoCell) {
    matchUserCell[cell.uid] = cell
  }
  
  func unregisterMatchUserCell(_ cell: UserInfoCell) {
    matchUserCell[cell.uid] = nil
  }
  
  func removeMatchesListener() {
    guard let uid = auth.uid else { return }
    databaseRef.child("matches/\(uid)").removeAllObservers()
  }
  
  func listenToMatches(
    completion: @escaping (Error?) -> Void
  ) {
    guard let currUserUid = auth.uid else {
      completion(AuthError.notSignedIn)
      return
    }
    let ref = databaseRef.child("matches/\(currUserUid)")
    ref.observe(.childAdded) { snapshot in
      MatchUser.insertNewMatchUser(key: snapshot.key, userDic: snapshot.value)
    } withCancel: { error in
      completion(error)
    }
  }
  
  
  func uploadRecentMessage(
    _ messageDic: [String: Any],
    from fromUid: String,
    to toUid: String,
    chatRoomId: String
  ) {
    uploadRecentMessage(messageDic, for: fromUid, chatRoomId: chatRoomId)
    uploadRecentMessage(messageDic, for: toUid, chatRoomId: chatRoomId)
  }
  
  private func uploadRecentMessage(
    _ messageDic: [String: Any],
    for forUid: String,
    chatRoomId: String
  ) {
    databaseRef.child("recentMessages/\(forUid)/\(chatRoomId)").runTransactionBlock {
      mutableData in
      // if there is old message, compare new with old creation date
      if let oldMessageDic = mutableData.value as? [String: Any] {
        if let creationDate = messageDic["creationDate"] as? Double,
           let oldCreationDate = oldMessageDic["creationDate"] as? Double,
           creationDate > oldCreationDate {
          mutableData.value = messageDic
        }
      } else {
        mutableData.value = messageDic
      }
      return TransactionResult.success(withValue: mutableData)
    }
  }
  
  var recentMessageCell: [String: UserInfoCell] = [:]
  
  func registerRecentMessageCell(_ cell: UserInfoCell) {
    recentMessageCell[cell.uid] = cell
  }
  
  func unregisterRecentMessageCell(_ cell: UserInfoCell) {
    recentMessageCell[cell.uid] = nil
  }
  
  func removeRecentMessagesListener() {
    guard let uid = auth.uid else { return }
    databaseRef.child("recentMessages/\(uid)").removeAllObservers()
  }
  
  func listenToRecentMessages(
    completion: @escaping (Error?) -> Void
  ) {
    guard let currUid = auth.uid else {
      completion(AuthError.notSignedIn)
      return
    }
    let ref = databaseRef.child("recentMessages/\(currUid)")
    ref.observe(.childAdded) { snapshot in
      Message.insertNewRecentMessage(key: snapshot.key, messageDic: snapshot.value)
    } withCancel: { error in
      completion(error)
    }
    ref.observe(.childChanged) { snapshot in
      Message.modifyRecentMessageWithKey(snapshot.key, with: snapshot.value)
    } withCancel: { error in
      completion(error)
    }
  }
  
  
  var cachedMatchUserInfo = [String: (name: String?, imageUrl: String?)]()

  func matchUserInfo(for uid: String) -> (String?, String?) {
    var userInfo = cachedMatchUserInfo[uid]
    if userInfo == nil {
      userInfo = (nil, nil)
      cachedMatchUserInfo[uid] = userInfo
      selectedMatchUid = uid
      fetchUsersInfoWithUid(uid)
    }
    return userInfo!
  }
  
  // when the user info arrived, db know which one is the selected one
  var selectedMatchUid: String?
  
  private func fetchUsersInfoWithUid(_ uid: String) {
    let ref = databaseRef.child("userInfos/\(uid)")
    ref.observeSingleEvent(of: .value) { snapshot in
      
    } withCancel: { error in
      print("fetch user info error ", error)
    }

    ref.getData { [weak self] error, snapshot in
      guard let self = self else { return }
      if let error = error {
        print("error in fetching user ", error)
        return
      }
      guard let userInfoDic = snapshot.value as? [String: Any] else {
        return
      }
      let name = userInfoDic["name"] as? String
      let imageUrl = userInfoDic["imageUrl0"] as? String
      // update the only source of truth
      self.cachedMatchUserInfo[uid] = (name, imageUrl)
      DispatchQueue.main.async {
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
  
  
  func uploadMessage(
    _ message: String,
    from fromUid: String,
    to toUid: String,
    chatRoomId: String,
    completion: @escaping (Error?) -> Void
  ) {
    let ref = databaseRef.child("messages/\(chatRoomId)").childByAutoId()
    guard let messageId = ref.key else {
      completion(DatabaseError.cantGetAutoId)
      return
    }
    let dataBlock: [String: Any] = [
      "fromUid": fromUid,
      "content": message,
      "type": "text",
      "toUid": toUid,
      "creationDate": Date().timeIntervalSince1970
    ]
    ref.setValue(dataBlock) { [weak self] error, ref in
      if error != nil {
        completion(error)
        return
      }
      // update the offset used to coordinate the firebase chat room messages for
      // the current device in user defaults
      self?.updateMessagesOffsetForUser(fromUid, chatRoomId: chatRoomId, with: messageId)
      completion(nil)
    }
    uploadRecentMessage(dataBlock, from: fromUid, to: toUid, chatRoomId: chatRoomId)
  }
  
  private var messagesQuery: DatabaseQuery?
  
  func removeMessagesListener() {
    messagesQuery?.removeAllObservers()
    messagesQuery = nil
  }
  
  func listenToMessages(
    from chatRoomId: String,
    completion: @escaping (Error?) -> Void
  ) {
    guard let currUid = auth.uid else {
      completion(AuthError.notSignedIn)
      return
    }
    // first find the messagesOffset, either in user defaults or firebase, if both doesn't
    // exist, just fetch all related messages in firebase
    let dispatchGroup = DispatchGroup()
    var query: DatabaseQuery = databaseRef.child("messages/\(chatRoomId)").queryOrderedByKey()
    var messagesOffset = UserDefaults(suiteName: currUid)?.string(forKey: chatRoomId)
    if messagesOffset == nil {
      let messagesOffsetRef = databaseRef.child("messagesOffset/\(currUid)/\(chatRoomId)")
      dispatchGroup.enter()
      messagesOffsetRef.getData { error, snapshot in
        defer { dispatchGroup.leave() }
        if let error = error {
          print("get messages offset error ", error)
        }
        messagesOffset = snapshot.value as? String
      }
    }
    dispatchGroup.notify(queue: .main) { [weak self] in
      if let offset = messagesOffset {
        query = query.queryStarting(afterValue: offset)
      }
      self?.messagesQuery = query
      query.observe(.childAdded) { [weak self] snapshot in
        guard let object = Message.dicFromChatRoomId(
          chatRoomId,
          messageId: snapshot.key,
          messageDic: snapshot.value
        ) else { return }
        let request = NSBatchInsertRequest(entity: Message.entity(), objects: [object])
        request.executeRequestBy(context: coreDataStack.mainContext)
        // if the message comes from current user
        if currUid == object["fromUid"] as? String {
          // mark the message status as "loading"
        } else {
          // if not, the message sync with firebase, so update user messages offset
          self?.updateMessagesOffsetForUser(currUid, chatRoomId: chatRoomId, with: object["id"] as? String)
        }
        completion(nil)
      } withCancel: { error in
        completion(error)
      }
    }

  }
  
  private func updateMessagesOffsetForUser(
    _ uid: String,
    chatRoomId: String,
    with newMessageId: String?
  ) {
    guard let userDefaults = UserDefaults(suiteName: uid),
          let newMessageId = newMessageId
    else { return }
    let currMessagId = userDefaults.string(forKey: chatRoomId)
    if currMessagId == nil || newMessageId > currMessagId! {
      userDefaults.setValue(newMessageId, forKey: chatRoomId)
    }
    databaseRef.child("messagesOffset/\(uid)/\(chatRoomId)").runTransactionBlock { currData in
      if let oldMessagesId = currData.value as? String {
        if oldMessagesId < newMessageId {
          currData.value = newMessageId
        }
      } else {
        currData.value = newMessageId
      }
      return TransactionResult.success(withValue: currData)
    }
  }
  
}
