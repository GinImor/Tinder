//
//  UIColor+constructor.swift
//  GILibrary
//
//  Created by Gin Imor on 1/30/21.
//
//

import UIKit

public extension UIColor {
  
  static func whiteWithAlpha(_ alpha: CGFloat) -> UIColor {
    return UIColor(white: 0.0, alpha: alpha)
  }
  
  convenience init(rgb: (red: Int, green: Int, blue: Int), alpha: CGFloat = 1.0) {
    self.init(red: CGFloat(rgb.red)/255,
              green: CGFloat(rgb.green)/255,
              blue: CGFloat(rgb.blue)/255, alpha: alpha
         )
  }
  
  convenience init(rgb: Int, alpha: CGFloat = 1.0) {
    let value = CGFloat(rgb) / 255
    self.init(red: value, green: value, blue: value, alpha: alpha)
  }
  
}
