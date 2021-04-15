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
  var name: String
  var age: Int?
  var profession: String?
  var imageUrls: [String?] = [nil, nil, nil]
  
  var minSeekingAge: Int
  var maxSeekingAge: Int
  
  init(userDic: [String: Any]) {
    self.uid = userDic["uid"] as? String ?? ""
    self.name = userDic["name"] as? String ?? ""
    self.age = userDic["age"] as? Int
    self.minSeekingAge = userDic["minSeekingAge"] as? Int ?? 18
    self.maxSeekingAge = userDic["maxSeekingAge"] as? Int ?? 50
    self.profession = userDic["profession"] as? String
    for i in 0..<imageUrls.count {
      imageUrls[i] = userDic["imageUrl\(i)"] as? String
      print("imageUrl\(i)", imageUrls[i] ?? "")
    }
  }
}

