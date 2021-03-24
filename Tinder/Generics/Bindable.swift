//
//  Bindable.swift
//  Tinder
//
//  Created by Gin Imor on 3/24/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import Foundation

struct Bindable<T> {
  
  var value: T? {
    didSet {
      observer?(value)
    }
  }
  
  var observer: ((T?) -> Void)?
  
  mutating func bind(observer: @escaping (T?) -> Void) {
    self.observer = observer
  }
  
}
