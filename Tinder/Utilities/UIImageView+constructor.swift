//
// UIImageView+constructor.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIImageView {
  
  static func system(imageName: String, size: CGFloat = 44, textStyle: UIFont.TextStyle? = nil, tintColor: UIColor? =
  nil) -> UIImageView {
    let imageView = UIImageView()
    let symbolConfiguration: UIImage.SymbolConfiguration
    if let textStyle = textStyle {
      symbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: textStyle))
    } else {
      symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size)
    }
    imageView.preferredSymbolConfiguration = symbolConfiguration
    imageView.image = UIImage(systemName: imageName)
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.tintColor = tintColor
    return imageView
  }
  
  static func new(imageName: String = "", contentMode: UIView.ContentMode = .scaleAspectFill) -> UIImageView {
    let imageView = UIImageView()
    if imageName != "" { imageView.image = UIImage(named: imageName) }
    imageView.contentMode = contentMode
    imageView.clipsToBounds = true
    return imageView
  }
}
