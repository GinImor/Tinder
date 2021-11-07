//
//  IndentedTextField.swift
//  GILibrary
//
//  Created by Gin Imor on 5/7/21.
//  
//

import UIKit

open class IndentedTextField: UITextField {
  
  let padding: CGFloat
  
  public init(_ padding: CGFloat = 8, _ placeholder: String = "", _ textStyle: UIFont.TextStyle? = nil) {
    self.padding = padding
    super.init(frame: .zero)
    self.placeholder = placeholder
    if let textStyle = textStyle {
      self.font = UIFont.preferredFont(forTextStyle: textStyle)
    }
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  open override func textRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: padding, dy: 0)
  }
  
  open override func editingRect(forBounds bounds: CGRect) -> CGRect {
      return bounds.insetBy(dx: padding, dy: 0)
  }
}
