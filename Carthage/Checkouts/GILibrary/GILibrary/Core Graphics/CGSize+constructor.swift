//
// CGSize+constructor.swift
// GILibrary
//
// Created by Gin Imor on 4/16/21.
//
//

import UIKit

public extension CGSize {
  
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
