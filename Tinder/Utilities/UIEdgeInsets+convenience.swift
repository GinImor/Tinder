//
//  UIEdgeInsets+convenience.swift
//  InstagramFirebase
//
//  Created by Gin Imor on 3/19/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
  
  init(top: CGFloat, leftRight: CGFloat, bottom: CGFloat) {
    self.init(top: top, left: leftRight, bottom: bottom, right: leftRight)
  }
  
  init(vertical: CGFloat, horizontal: CGFloat) {
    self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
  }
  
  init(_ padding: CGFloat) {
    self.init(top: padding, left: padding, bottom: padding, right: padding)
  }
  
  var leftRight: (left: CGFloat, right: CGFloat) {
    get { (left, right) }
    set {
      left = newValue.left
      right = newValue.right
    }
  }
  
  var topBottom: (top: CGFloat, bottom: CGFloat) {
    get { (top, bottom) }
    set {
      top = newValue.top
      bottom = newValue.bottom
    }
  }
  
  var topLeftRight: (top: CGFloat, left: CGFloat, right: CGFloat) {
    get { (top, left, right) }
    set {
      top = newValue.top
      left = newValue.left
      right = newValue.right
    }
  }

  var bottomLeftRight: (bottom: CGFloat, left: CGFloat, right: CGFloat) {
    get { (bottom, left, right) }
    set {
      bottom = newValue.bottom
      left = newValue.left
      right = newValue.right
    }
  }
}
