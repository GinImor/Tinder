//
//  MatchUser+convenience.swift
//  Tinder
//
//  Created by Gin Imor on 12/5/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import CoreData

extension MatchUser {
  
  static func dicFromKey(_ key: String, _ userDic: [String: Any]?) -> [String: Any] {
    var result: [String: Any] = ["id": key]
    result["matchedUid"] = auth.uid
    result["matchDate"] = userDic?["matchDate"] as? Double
    if let cloudChatRoomId = userDic?["chatRoomId"] as? String {
      result["chatRoomId"] = "\(cloudChatRoomId) \(key)"
    }
    return result
  }
  
  static func insertNewMatchUser(key: String, userDic: Any?) {
    guard let userDic = userDic as? [String: Any] else { return }
    let matchUser = MatchUser(context: tempDataStack.mainContext)
    matchUser.id = key
    matchUser.matchDate = userDic["matchDate"] as? Double ?? Date().timeIntervalSince1970
    if let cloudChatRoomId = userDic["chatRoomId"] as? String {
      matchUser.chatRoomId = "\(cloudChatRoomId) \(key)"
    }
    tempDataStack.saveContext()
  }
  
}
