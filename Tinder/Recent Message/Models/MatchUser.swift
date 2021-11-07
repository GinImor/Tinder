//
// MatchUser.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import Foundation
import Firebase

struct MatchUser: IdentifiableUser {
  
  let uid: String

  init(userDic: [String: Any]) {
    self.uid = userDic["uid"] as? String ?? ""
  }
}
