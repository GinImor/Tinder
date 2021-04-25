//
// RecentMessage.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import Foundation
import Firebase

struct RecentMessage {
  let uid, text, username, profileImageUrl: String
  let timestamp: Timestamp
  
  init(messageDic: [String: Any]) {
    self.uid = messageDic["uid"] as? String ?? ""
    self.text = messageDic["text"] as? String ?? ""
    self.username = messageDic["username"] as? String ?? ""
    self.profileImageUrl = messageDic["profileImageUrl"] as? String ?? ""
    self.timestamp = messageDic["timestamp"] as? Timestamp ?? Timestamp(date: Date())
  }
  
  func compare(_ message2: RecentMessage) -> Bool {
    timestamp.compare(message2.timestamp) == .orderedDescending
  }
}
