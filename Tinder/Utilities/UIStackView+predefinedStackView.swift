//
//  UIStackView+verticalStackView.swift
//  Podcast
//
//  Created by Gin Imor on 2/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIStackView {
  
  /// Creates a stack view configured for displaying content vertically.
  public static func verticalStack(arrangedSubviews: [UIView]) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: arrangedSubviews)
    stack.axis = .vertical
    stack.spacing = 8
    stack.disableTAMIC()
    return stack
  }
  
  @discardableResult
  public static func verticalStack(arrangedSubviews: [UIView], pinToSuperview pinedView: UIView? = nil, edgeInsets: UIEdgeInsets) -> UIStackView {
    let stackView = UIStackView.verticalStack(arrangedSubviews: arrangedSubviews)
    pinedView?.addSubview(stackView)
    stackView.pinToSuperviewEdges(edgeInsets: edgeInsets)
    return stackView
  }
  
  public static func horizontalFillEqualStack(arrangedSubviews: [UIView], superView: UIView? = nil) -> UIStackView {
    let stack = UIStackView(arrangedSubviews: arrangedSubviews)
    superView?.addSubview(stack)
    stack.axis = .horizontal
    stack.disableTAMIC()
    stack.distribution = .fillEqually
    return stack
  }
  
}
