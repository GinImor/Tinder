//
// UILabel+constructor.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UILabel {
  
  static func new(_ text: String? = nil, textStyle: UIFont.TextStyle = .footnote, textColor: UIColor? = nil,
                  textAlignment: NSTextAlignment? = nil) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.preferredFont(forTextStyle: textStyle)
    if let textColor = textColor { label.textColor = textColor }
    if let textAlignment = textAlignment { label.textAlignment = textAlignment }
    return label
  }
}