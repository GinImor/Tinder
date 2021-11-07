//
//  PaddingTextField.swift
//  Tinder
//
//  Created by Gin Imor on 3/23/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class PaddingTextField: UITextField {
  
  var paddingX: CGFloat = 8

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: paddingX, dy: 0)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return bounds.insetBy(dx: paddingX, dy: 0)
  }
}

class PaddingCellTextField: PaddingTextField {
  
  override var intrinsicContentSize: CGSize {
    CGSize(width: 0, height: 44)
  }
}
