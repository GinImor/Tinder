//
// RecentMessage.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

struct RecentMessage: IdentifiableUser {
  let uid: String
  var text: String?
  
  init(messageDic: [String: Any]) {
    self.uid = messageDic["uid"] as? String ?? ""
    self.text = messageDic["text"] as? String
  }
}
