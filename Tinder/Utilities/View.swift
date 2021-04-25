//
// View.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

enum LayerShadow {
  case opacity(Float)
  case radius(CGFloat)
  case offset(CGSize)
  case color(UIColor?)
  case path(CGPath?)
}

struct View<T: UIView> {
  let view: T
  var layer: CALayer { view.layer }
  
  init(_ view: T = UIView() as! T, insets: UIEdgeInsets = .zero, subView: UIView) {
    self.view = view
    subView.add(to: view).filling(edgeInsets: insets)
  }
  
  @discardableResult
  func backgroundColor(_ color: UIColor) -> Self {
    view.backgroundColor = color
    return self
  }
  
  @discardableResult
  func shadow(_ values: LayerShadow...) -> Self {
    values.forEach {
      switch $0 {
      case let .opacity(opacity):
        layer.shadowOpacity = opacity
      case let .radius(radius):
        layer.shadowRadius = radius
      case let .offset(offset):
        layer.shadowOffset = offset
      case let .color(color):
        layer.shadowColor = color?.cgColor
      case let .path(path):
        layer.shadowPath = path
      }
    }
    return self
  }
  
}
