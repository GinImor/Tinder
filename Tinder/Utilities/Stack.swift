//
// Stack.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

protocol Stack {
  var view: UIStackView { get }
  func spacing(_ value: CGFloat) -> Stack
  func distribution(_ value: UIStackView.Distribution) -> Stack
}

extension Stack {
  
  func spacing(_ value: CGFloat = 8.0) -> Stack {
  view.spacing = value
  return self
}

func distribution(_ value: UIStackView.Distribution) -> Stack {
  view.distribution = value
  return self
}

func aliment(_ value: UIStackView.Alignment) -> Stack {
  view.alignment = value
  return self
}
}

struct HStack: Stack {

  let view: UIStackView
  
  init(_ views: UIView...) {
    view = UIStackView(arrangedSubviews: views)
  }
  
}

struct VStack: Stack {
  let view: UIStackView
  
  init(_ views: UIView...) {
    view = UIStackView(arrangedSubviews: views)
    view.axis = .vertical
  }
}