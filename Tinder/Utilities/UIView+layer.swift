//
// UIView+layer.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIView {
  
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