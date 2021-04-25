//
//  UIColor+constructor.swift
//  IntermediateTraining
//
//  Created by Gin Imor on 1/30/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIColor {
  
  static var primaryColor = #colorLiteral(red: 0.9778892398, green: 0.3299795985, blue: 0.3270179033, alpha: 1)
  
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
