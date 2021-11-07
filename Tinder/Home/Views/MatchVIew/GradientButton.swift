//
// GradientButton.swift
// Tinder
//
// Created by Gin Imor on 4/16/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class GradientButton: UIButton {
  
  let gradientLayer = CAGradientLayer()
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    gradientLayer.colors = [#colorLiteral(red: 0.9778892398, green: 0.3299795985, blue: 0.3270179033, alpha: 1).cgColor, #colorLiteral(red: 0.8706625104, green: 0.1032681242, blue: 0.4151168168, alpha: 1).cgColor]
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
    gradientLayer.frame = rect
    layer.insertSublayer(gradientLayer, at: 0)
    layer.cornerRadius = rect.height / 2
    layer.masksToBounds = true
  }
}
