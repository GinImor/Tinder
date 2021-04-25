//
// CGSize+utilities.swift
// Tinder
//
// Created by Gin Imor on 4/16/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension CGSize {
  
  init(widthHeight: CGFloat) {
    self.init(width: widthHeight, height: widthHeight)
  }
  
  init(width: CGFloat) {
    self.init(width: width, height: 0)
  }
  
  init(height: CGFloat) {
    self.init(width: 0, height: height)
  }
  
}