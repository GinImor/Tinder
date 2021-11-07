//
//  UIImageView+constructor.swift
//  GILibrary
//
//  Created by Gin Imor on 4/20/21.
//
//

import UIKit

public extension UIImageView {
  
  @available(iOS 13.0, *)
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
  
  static func new(imageName: String = "", cornerRadius: CGFloat = 8,
                  contentMode: UIView.ContentMode = .scaleAspectFill) -> UIImageView {
    let imageView = UIImageView()
    if imageName != "" { imageView.image = UIImage(named: imageName) }
    imageView.layer.cornerRadius = cornerRadius
    imageView.contentMode = contentMode
    imageView.clipsToBounds = true
    return imageView
  }
}
