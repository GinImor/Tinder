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
    // .nonZero, a ray crossed how many left-to-right paths(+1), how many right-to-left paths(-1),
    // if the result is nonZero, fill the area, don't otherwise
    // .evenOdd, a ray crossed how many paths,
    // if the result is odd, fill the area, don't otherwise
    // do notice that an implicit (non-rendered) line from the first to the last point of the subpath
    // will be considered as a normal path when counting
    maskLayer.fillRule = .evenOdd
    maskLayer.path = path
    gradientLayer.mask = maskLayer
  }
}
