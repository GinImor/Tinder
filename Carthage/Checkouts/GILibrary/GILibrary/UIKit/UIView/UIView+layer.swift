//
//  UIView+layer.swift
//  GILibrary
// 
//  Created by Gin Imor on 4/20/21.
//
//

import UIKit

public extension UIView {
  
  @discardableResult
  func roundedCorner(_ radius: CGFloat) -> Self {
    layer.cornerRadius = radius
    layer.masksToBounds = true
    return self
  }
  
  @discardableResult
  func shadow(opacity: Float, radius: CGFloat, offset: CGSize,
              color: UIColor? = nil, path: CGPath? = nil
  ) -> Self {
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius
    layer.shadowOffset = offset
    layer.shadowColor = color?.cgColor
    layer.shadowPath = path
    return self
  }
}
