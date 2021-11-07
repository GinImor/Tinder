//
//  UIView+oneSideBorder.swift
//  GILibrary
//
//  Created by Gin Imor on 4/23/21.
//
//

import UIKit

public extension UIView {
  
  func addBottomBorder(leftPad: CGFloat) {
    let borderView = newBorderView()
    NSLayoutConstraint.activate([
      borderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftPad),
      borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
      borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
      borderView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
  
  func addBottomBorder(leadingAnchor: NSLayoutXAxisAnchor) {
    let borderView = newBorderView()
    NSLayoutConstraint.activate([
      borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
      borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
      borderView.bottomAnchor.constraint(equalTo: bottomAnchor),
      borderView.heightAnchor.constraint(equalToConstant: 0.5)
    ])
  }
  
  private func newBorderView() -> UIView {
    UIView(backgroundColor: UIColor(white: 0.6, alpha: 0.5)).add(to: self)
  }
  
}
