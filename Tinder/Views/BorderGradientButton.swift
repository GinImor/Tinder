//
// BorderGradientButton.swift
// Tinder
//
// Created by Gin Imor on 4/16/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class BorderGradientButton: GradientButton {
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    let path = CGMutablePath()
    let cornerRadius = rect.height / 2
    path.addPath(UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath)
    path.addPath(UIBezierPath(roundedRect: rect.insetBy(dx: 2, dy: 2), cornerRadius: cornerRadius).cgPath)
    let maskLayer = CAShapeLayer()
    maskLayer.fillRule = .evenOdd
    maskLayer.path = path
    gradientLayer.mask = maskLayer
    gradientLayer.frame = rect
    layer.insertSublayer(gradientLayer, at: 0)
  }
}
