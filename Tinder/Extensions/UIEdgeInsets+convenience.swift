//
//  UIEdgeInsets+convenience.swift
//  InstagramFirebase
//
//  Created by Gin Imor on 3/19/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
  
  init(padding: (top: CGFloat, leftRight: CGFloat, bottom: CGFloat)) {
    self.init(
      top: padding.top,
      left: padding.leftRight,
      bottom: padding.bottom,
      right: padding.leftRight)
  }
  
  init(padding: (vertical: CGFloat, horizontal: CGFloat)) {
    self.init(
      top: padding.vertical,
      left: padding.horizontal,
      bottom: padding.vertical,
      right: padding.horizontal)
  }
  
  init(padding: CGFloat) {
    self.init(top: padding, left: padding, bottom: padding, right: padding)
  }
  
}
