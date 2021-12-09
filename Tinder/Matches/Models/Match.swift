//
//  Match.swift
//  Tinder
//
//  Created by Gin Imor on 12/6/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

struct Match {
  
  let uid: String
  let cloudChatRoomId: String
  let localChatRoomId: String
  
  init(_ _localChatRoomId: String) {
    let startIndex = _localChatRoomId.startIndex
    let endIndex = _localChatRoomId.endIndex
    let spaceIndex = _localChatRoomId.firstIndex(of: " ")!
    let uidStartIndex = _localChatRoomId.index(spaceIndex, offsetBy: +1)
    uid = String(_localChatRoomId[uidStartIndex..<endIndex])
    cloudChatRoomId = String(_localChatRoomId[startIndex..<spaceIndex])
    localChatRoomId = _localChatRoomId
  }
  
  init(uid: String, cloudChatRoomId: String) {
    self.uid = uid
    self.cloudChatRoomId = cloudChatRoomId
    self.localChatRoomId = "\(cloudChatRoomId) \(uid)"
  }
  
}
