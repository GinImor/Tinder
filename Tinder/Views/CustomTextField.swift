//
//  CustomTextField.swift
//  Tinder
//
//  Created by Gin Imor on 3/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {
  
  var paddingX: CGFloat?

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    guard let paddingX = paddingX else { return super.textRect(forBounds: bounds) }
    return bounds.insetBy(dx: paddingX, dy: 0)
  }
  
  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    guard let paddingX = paddingX else { return super.editingRect(forBounds: bounds) }
    return bounds.insetBy(dx: paddingX, dy: 0)
  }
}
