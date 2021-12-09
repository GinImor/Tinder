//
//  UIView+border.swift
//  Tinder
//
//  Created by Gin Imor on 12/11/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIView {
  
  func addBorder(width: CGFloat, uiColor: UIColor) {
    layer.borderWidth = width
    layer.borderColor = uiColor.cgColor
  }
}
