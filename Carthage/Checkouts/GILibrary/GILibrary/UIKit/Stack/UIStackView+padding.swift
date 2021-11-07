//
//  UIStackView+padding.swift
//  GILibrary
//
//  Created by Gin Imor on 4/18/21.
//
//

import UIKit

public extension UIStackView {
  
  enum Direction {
    case top, left, bottom, right
  }

  @discardableResult
  func padding(_ direction: Direction, value: CGFloat = 16) -> UIStackView {
    isLayoutMarginsRelativeArrangement = true
    switch direction {
    case .top: layoutMargins.top = value
    case .left: layoutMargins.left = value
    case .bottom: layoutMargins.bottom = value
    case .right: layoutMargins.right = value
    }
    return self
  }
  
  @discardableResult
  func padding(edgeInsets: UIEdgeInsets = .init(16)) -> UIStackView {
    isLayoutMarginsRelativeArrangement = true
    layoutMargins = edgeInsets
    return self
  }
  
}
