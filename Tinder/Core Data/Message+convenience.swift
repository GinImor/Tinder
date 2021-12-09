//
//  Message+convenience.swift
//  Tinder
//
//  Created by Gin Imor on 12/6/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

extension Message {
  
  static func dicFromChatRoomId(
    _ chatRoomId: String,
    messageId: String,
    messageDic: Any?
  ) -> [String: Any]? {
    guard var messageDic = messageDic as? [String: Any],
          let fromUid = messageDic["fromUid"] as? String,
          let toUid = messageDic["toUid"] as? String else { return nil }
    messageDic["id"] = messageId
    messageDic["chatRoomId"] = "\(chatRoomId) \(fromUid == auth.uid ? toUid : fromUid)"
    return messageDic
  }
  
  static func insertNewRecentMessage(key: String, messageDic: Any?) {
    guard let messageDic = messageDic as? [String: Any] else { return }
    let message = Message(context: tempDataStack.mainContext)
    populateMessage(message, withDic: messageDic)
    message.chatRoomId = key
    tempDataStack.saveContext()
  }
  
  static func modifyRecentMessageWithKey(_ key: String, with messageDic: Any?) {
    guard let messageDic = messageDic as? [String: Any] else { return }
    let request = Message.fetchRequest()
    request.predicate = NSPredicate(format: "chatRoomId == %@", key)
    do {
      let result = try tempDataStack.mainContext.fetch(request)
      if result.count == 0 {
        insertNewRecentMessage(key: key, messageDic: messageDic)
      } else if let old = result.first,
                let newDate = messageDic["creationDate"] as? Double,
                newDate > old.creationDate {
        populateMessage(old, withDic: messageDic)
        tempDataStack.saveContext()
      }
    } catch {
      print("modify recent message error ", error)
    }
  }
  
  static func populateMessage(_ message: Message, withDic messageDic: [String: Any]) {
    message.fromUid = messageDic["fromUid"] as? String
    message.toUid = messageDic["toUid"] as? String
    message.creationDate = messageDic["creatinoDate"] as? Double ?? Date().timeIntervalSince1970
    message.content = messageDic["content"] as? String
    message.type = messageDic["type"] as? String
  }
  
}
