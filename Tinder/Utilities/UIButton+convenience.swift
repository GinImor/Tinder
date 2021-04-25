//
// UIButton+convenience.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIButton {
  
  func addTarget(_ target: Any?, action: Selector) {
    addTarget(target, action: action, for: .touchUpInside)
  }
}