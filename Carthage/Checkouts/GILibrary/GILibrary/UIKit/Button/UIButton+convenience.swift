//
//  UIButton+convenience.swift
//  GILibrary
//
//  Created by Gin Imor on 4/20/21.
//
//

import UIKit

public extension UIControl {
  
  func addTarget(_ target: Any?, action: Selector) {
    addTarget(target, action: action, for: .primaryActionTriggered)
  }
}
