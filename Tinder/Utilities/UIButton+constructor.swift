//
// UIButton+constructor.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIButton {
  
  static func system(imageName: String, size: CGFloat = 44, textStyle: UIFont.TextStyle? = nil, tintColor: UIColor) ->
    UIButton {
    let button = UIButton(type: .system)
    let symbolConfiguration: UIImage.SymbolConfiguration
    if let textStyle = textStyle {
      symbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: textStyle))
    } else {
      symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size)
    }
    let image = UIImage(systemName: imageName)?.withConfiguration(symbolConfiguration)
    button.setImage(image, for: .normal)
    button.tintColor = tintColor
    return button
  }
  
  static func new(imageName: String) -> UIButton {
    let button = UIButton()
    button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
    return button
  }
  
  static func system(text: String, tintColor: UIColor? = nil) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(text, for: .normal)
    if let tintColor = tintColor {
      button.tintColor = tintColor
    }
    return button
  }
}
