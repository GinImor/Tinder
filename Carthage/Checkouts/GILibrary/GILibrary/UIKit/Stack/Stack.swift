//
//  Stack.swift
//  GILibrary
// 
//  Created by Gin Imor on 4/19/21.
//
//

import UIKit

public extension UIStackView {
  
  convenience init(_ views: [UIView], _ spacing: CGFloat = 8.0) {
    self.init(arrangedSubviews: views)
    self.spacing = spacing
  }
  
  func spacing(_ value: CGFloat = 8.0) -> Self {
    spacing = value
    return self
  }
  
  func distributing(_ value: UIStackView.Distribution) -> Self {
    distribution = value
    return self
  }
  
  func aligning(_ value: UIStackView.Alignment) -> Self {
    alignment = value
    return self
  }
}

public func vStack(_ views: UIView...) -> UIStackView {
  let stackView = UIStackView(views)
  stackView.axis = .vertical
  return stackView
}

public func vStack(_ views: [UIView]) -> UIStackView {
  let stackView = UIStackView(views)
  stackView.axis = .vertical
  return stackView
}

public func hStack(_ views: UIView...) -> UIStackView {
  UIStackView(views)
}

public func hStack(_ views: [UIView]) -> UIStackView {
  UIStackView(views)
}
