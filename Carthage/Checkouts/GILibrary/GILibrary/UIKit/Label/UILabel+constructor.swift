//
//  UILabel+constructor.swift
//  GILibrary
//
//  Created by Gin Imor on 4/27/21.
//
//

import UIKit

public extension UILabel {
  
  static func new(_ text: String = "", attributes: [NSAttributedString.Key: Any]? = nil) -> UILabel {
    let label = UILabel()
    label.attributedText = NSAttributedString(string: text, attributes: attributes)
    return label
  }
  
  static func new(_ text: String, _ textStyle: UIFont.TextStyle, _ lines: Int = 1) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.preferredFont(forTextStyle: textStyle)
    label.numberOfLines = lines
    return label
  }
  
  static func new(_ text: String, _ textStyle: UIFont.TextStyle, _ textColor: UIColor, _ textAlignment: NSTextAlignment
  ) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.preferredFont(forTextStyle: textStyle)
    label.textColor = textColor
    label.textAlignment = textAlignment
    return label
  }
}
