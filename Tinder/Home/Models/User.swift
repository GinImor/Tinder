//
//  User.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

protocol IdentifiableUser {
  var uid: String { get }
}

struct User: IdentifiableUser {
  
  struct Info {
    let uid: String
    var name: String
    var age: Int?
    var bio: String?
    var profession: String?
    var imageUrls: [String?] = [nil, nil, nil]
    
    init(key: String, dic: [String: Any]) {
      self.uid = key
      self.name = dic["name"] as? String ?? ""
      self.age = dic["age"] as? Int
      self.bio = dic["bio"] as? String
      self.profession = dic["profession"] as? String
      for i in 0..<imageUrls.count {
        imageUrls[i] = dic["imageUrl\(i)"] as? String
      }
    }
  }
  
  struct Preference {
    var minSeekingAge: Int
    var maxSeekingAge: Int
    
    init(dic: [String: Any]) {
      self.minSeekingAge = dic["minSeekingAge"] as? Int ?? 18
      self.maxSeekingAge = dic["maxSeekingAge"] as? Int ?? 35
    }
  }
  
  var uid: String { return info.uid }
  
  var info: Info
  var preference: Preference
  
  init(key: String, infoDic: [String: Any], prefDic: [String: Any]) {
    self.info = Info(key: key, dic: infoDic)
    self.preference = Preference(dic: prefDic)
  }
  
}

