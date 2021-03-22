//
//  UIView+tAMIC.swift
//  IntermediateTraining
//
//  Created by Gin Imor on 1/31/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIView {
  
  var tAMIC: Bool {
    get { translatesAutoresizingMaskIntoConstraints }
    set { translatesAutoresizingMaskIntoConstraints = newValue }
  }
  
  func disableTAMIC() {
    tAMIC = false
  }
  
  public static let defaultPadding: CGFloat = 8.0

  /// Creates a new instance of the receiver class, configured for use with Auto Layout.
  /// - Returns: An instance of the receiver class.
  public static func autolayoutNew() -> Self {
    let view = self.init(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  func pinToSuperviewEdges(edgeInsets: UIEdgeInsets = .zero, pinnedView: UIView? = nil, forSelfSizing: Bool = false) {
    pinnedView?.addSubview(self)
    guard let superview = superview else { return }
    disableTAMIC()
    
    let bottomConstraint = bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -edgeInsets.bottom)
    if forSelfSizing {
      bottomConstraint.priority = UILayoutPriority(rawValue: 750)
    }
    NSLayoutConstraint.activate([
      topAnchor.constraint(equalTo: superview.topAnchor, constant: edgeInsets.top),
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: edgeInsets.left),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -edgeInsets.right),
      bottomConstraint
    ])
  }
  
  func centerToSuperviewSafeAreaLayoutGuide() {
    guard let superview = superview else { return }
    disableTAMIC()
    NSLayoutConstraint.activate([
      centerXAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.centerXAnchor),
      centerYAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.centerYAnchor)
    ])
  }
  
  func centerToSuperviewSafeAreaLayoutGuide(superview: UIView) {
    superview.addSubview(self)
    centerToSuperviewSafeAreaLayoutGuide()
  }
  
  func pinToSuperviewHorizontalEdges(defaultSpacing: CGFloat = 0, trailingSpacing: CGFloat? = nil) {
    guard let superview = superview else { return }
    NSLayoutConstraint.activate([
        leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: defaultSpacing),
        trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -(trailingSpacing ?? defaultSpacing))
    ])
  }
}
