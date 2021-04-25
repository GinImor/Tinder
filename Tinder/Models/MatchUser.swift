//
// MatchUser.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

protocol UserModel {
  var name: String { get }
  var profileImageUrl: String { get }
  var uid: String { get }
}

struct MatchUser: UserModel {
  let name, profileImageUrl, uid: String
  
  init(userDic: [String: Any]) {
    self.name = userDic["name"] as? String ?? ""
    self.profileImageUrl = userDic["profileImageUrl"] as? String ?? ""
    self.uid = userDic["uid"] as? String ?? ""
  }
}

extension User: UserModel {
  var profileImageUrl: String {
    validImageUrls.first ?? ""
  }
}