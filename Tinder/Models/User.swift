//
//  User.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

struct User {
  let uid: String
  let name: String
  var age: Int?
  var profession: String
  var imageUrl1: String
  
  init(userDic: [String: Any]) {
    self.uid = userDic["uid"] as? String ?? ""
    self.name = userDic["name"] as? String ?? ""
    self.age = userDic["age"] as? Int
    self.profession = userDic["profession"] as? String ?? ""
    self.imageUrl1 = userDic["imageUrl1"] as? String ?? ""
  }
}

