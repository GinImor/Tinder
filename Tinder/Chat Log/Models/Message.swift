//
// Message.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import Foundation
import Firebase

struct Message {
  let fromUid: String
  let text: String
  let toUid: String
  let timestamp: Timestamp
  
  var isFromCurrentUser: Bool
  
  init(dataDic: [String: Any]) {
    self.fromUid = dataDic["fromUid"] as? String ?? ""
    self.text = dataDic["text"] as? String ?? ""
    self.toUid = dataDic["toUid"] as? String ?? ""
    self.timestamp = dataDic["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    self.isFromCurrentUser = self.fromUid == Auth.auth().currentUser?.uid
  }
  
}

