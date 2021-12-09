//
//  Message+computed.swift
//  Tinder
//
//  Created by Gin Imor on 12/3/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import CoreData

extension Message {
  
  var isFromCurrUser: Bool { fromUid == auth.uid }
  
  var chattingUid: String { isFromCurrUser ? (toUid ?? "") : (fromUid ?? "") }
}
