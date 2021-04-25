//
//  UIView+tAMIC.swift
//  IntermediateTraining
//
//  Created by Gin Imor on 1/31/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

protocol AnchorObject: class {
  var bottomAnchor: NSLayoutYAxisAnchor {get}
  var centerXAnchor: NSLayoutXAxisAnchor {get}
  var centerYAnchor: NSLayoutYAxisAnchor {get}
  var heightAnchor: NSLayoutDimension {get}
  var leadingAnchor: NSLayoutXAxisAnchor {get}
  var leftAnchor: NSLayoutXAxisAnchor {get}
  var rightAnchor: NSLayoutXAxisAnchor {get}
  var topAnchor: NSLayoutYAxisAnchor {get}
  var trailingAnchor: NSLayoutXAxisAnchor {get}
  var widthAnchor: NSLayoutDimension {get}
  var firstBaselineAnchor: NSLayoutYAxisAnchor {get}
  var lastBaselineAnchor: NSLayoutYAxisAnchor {get}
}

extension UIView: AnchorObject {}
extension UILayoutGuide: AnchorObject {
  var firstBaselineAnchor: NSLayoutYAxisAnchor { topAnchor }
  var lastBaselineAnchor: NSLayoutYAxisAnchor { bottomAnchor }
}

enum HorizontalAnchor {
  case leading, trailing, horizontal, centerX
}

enum VerticalAnchor {
  case top, bottom, vertical, centerY, firstBaseline, lastBaseline
}

enum SizeAnchor {
  case width, height
}

extension NSLayoutConstraint {
  
  @discardableResult
  func withPriority(value: Float) -> NSLayoutConstraint {
    priority = UILayoutPriority(rawValue: value)
    return self
  }
  
  @discardableResult
  func activate() -> UIView? {
    isActive = true
    return firstItem as? UIView
  }
}

extension UIView {
  
  static func new(backgroundColor: UIColor) -> UIView {
    let view = UIView()
    view.backgroundColor = backgroundColor
    return view
  }
  
  @discardableResult
  func add(to view: UIView) -> Self {
    view.addSubview(self)
    return self
  }
  
  @discardableResult
  func withHugging(_ hugging: Float, compressionResistance: Float, axis: NSLayoutConstraint.Axis = .vertical) -> Self {
    setContentHuggingPriority(UILayoutPriority(rawValue: hugging), for: axis)
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: compressionResistance), for: axis)
    return self
  }
  
  @discardableResult
  func withHugging(_ priority: Float, axis: NSLayoutConstraint.Axis = .vertical) -> Self {
    setContentHuggingPriority(UILayoutPriority(rawValue: priority), for: axis)
    return self
  }
  
  @discardableResult
  func withCompressionResistance(_ priority: Float, axis: NSLayoutConstraint.Axis = .vertical) -> Self {
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: priority), for: axis)
    return self
  }
  
  @discardableResult
  func hLining(
    _ anchor: HorizontalAnchor,
    to linedObject: AnchorObject? = nil,
    _ linedAnchor: HorizontalAnchor? = nil,
    value: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _linedObject = linedObject ?? superview?.safeAreaLayoutGuide else { return self }
    disableTAMIC()
    var constraints = [NSLayoutConstraint]()
    if anchor == .horizontal {
      constraints.append(leadingAnchor.constraint(equalTo: _linedObject.leadingAnchor, constant: value))
      constraints.append(trailingAnchor.constraint(equalTo: _linedObject.trailingAnchor, constant: -value))
    } else {
      let _linedAnchor = linedAnchor ?? anchor
      let anchoringObjects = [self, _linedObject]
      let anchors = [anchor, _linedAnchor]
      var uikitAnchors: [NSLayoutXAxisAnchor] = []
      for i in 0..<2 {
        switch anchors[i] {
        case .leading: uikitAnchors.append(anchoringObjects[i].leadingAnchor)
        case .trailing: uikitAnchors.append(anchoringObjects[i].trailingAnchor)
        case .centerX: uikitAnchors.append(anchoringObjects[i].centerXAnchor)
        case .horizontal: return self
        }
      }
      constraints.append(uikitAnchors[0].constraint(equalTo: uikitAnchors[1], constant: value))
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func vLining(
    _ anchor: VerticalAnchor,
    to linedObject: AnchorObject? = nil,
    _ linedAnchor: VerticalAnchor? = nil,
    value: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _linedObject = linedObject ?? superview?.safeAreaLayoutGuide else { return self }
    disableTAMIC()
    let constraints: [NSLayoutConstraint]
    if anchor == .vertical {
      constraints = [
        topAnchor.constraint(equalTo: _linedObject.topAnchor, constant: value),
        bottomAnchor.constraint(equalTo: _linedObject.bottomAnchor, constant: -value)
      ]
    } else {
      let _linedAnchor = linedAnchor ?? anchor
      let anchoringObjects = [self, _linedObject]
      let anchors = [anchor, _linedAnchor]
      var uikitAnchors: [NSLayoutYAxisAnchor] = []
      for i in 0..<2 {
        switch anchors[i] {
        case .top: uikitAnchors.append(anchoringObjects[i].topAnchor)
        case .bottom: uikitAnchors.append(anchoringObjects[i].bottomAnchor)
        case .centerY: uikitAnchors.append(anchoringObjects[i].centerYAnchor)
        case .firstBaseline: uikitAnchors.append(anchoringObjects[i].firstBaselineAnchor)
        case .lastBaseline: uikitAnchors.append(anchoringObjects[i].lastBaselineAnchor)
        case .vertical: return self
        }
      }
      constraints = [uikitAnchors[0].constraint(equalTo: uikitAnchors[1], constant: value)]
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func filling(
    _ filledObject: AnchorObject? = nil,
    edgeInsets: UIEdgeInsets = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _filledObject = filledObject ?? superview?.safeAreaLayoutGuide else { return self }
    disableTAMIC()
    let constraints = [
      topAnchor.constraint(equalTo: _filledObject.topAnchor, constant: edgeInsets.top),
      leadingAnchor.constraint(equalTo: _filledObject.leadingAnchor, constant: edgeInsets.left),
      bottomAnchor.constraint(equalTo: _filledObject.bottomAnchor, constant: -edgeInsets.bottom),
      trailingAnchor.constraint(equalTo: _filledObject.trailingAnchor, constant: -edgeInsets.right)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func centering(
    _ centeredObject: AnchorObject? = nil,
    vector: CGVector = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _centeredObject = centeredObject ?? superview?.safeAreaLayoutGuide else { return self }
    disableTAMIC()
    let constraints = [
      centerXAnchor.constraint(equalTo: _centeredObject.centerXAnchor, constant: vector.dx),
      centerYAnchor.constraint(equalTo: _centeredObject.centerYAnchor, constant: vector.dy)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func sizing(
    to sizedObject: AnchorObject? = nil,
    widthMultiplier: CGFloat = 1.0,
    widthDelta: CGFloat = 0,
    heightMultiplier: CGFloat = 1.0,
    heightDelta: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
) -> Self {
    guard let _sizedObject = sizedObject ?? superview?.safeAreaLayoutGuide else { return self }
    disableTAMIC()
    let constraints = [
      widthAnchor.constraint(equalTo: _sizedObject.widthAnchor, multiplier: widthMultiplier, constant: widthDelta),
      heightAnchor.constraint(equalTo: _sizedObject.heightAnchor, multiplier: heightMultiplier, constant: heightDelta)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func sizing(
    _ anchor: SizeAnchor,
    to sizedObject: AnchorObject? = nil,
    _ sizedAnchor: SizeAnchor?,
    multiplier: CGFloat = 1.0,
    delta: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    disableTAMIC()
    let _sizedObject = sizedObject ?? self
    let _sizedAnchor = sizedAnchor ?? anchor
    let anchoringObjects = [self, _sizedObject]
    let anchors = [anchor, _sizedAnchor]
    var uikitAnchors: [NSLayoutDimension] = []
    for i in 0..<2 {
      switch anchors[i] {
      case .width: uikitAnchors[i] = anchoringObjects[i].widthAnchor
      case .height: uikitAnchors[i] = anchoringObjects[i].heightAnchor
      }
    }
    let constraint = uikitAnchors[0].constraint(equalTo: uikitAnchors[1], multiplier: multiplier, constant: delta)
    constraint.isActive = true
    constraintsHandler?([constraint])
    return self
  }
  
  @discardableResult
  func sizing(
    width: CGFloat = 0,
    height: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    disableTAMIC()
    var constraints = [NSLayoutConstraint]()
    if width > 0 { constraints.append(widthAnchor.constraint(equalToConstant: width)) }
    if height > 0 { constraints.append(heightAnchor.constraint(equalToConstant: height)) }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func sizing(
    to value: CGFloat,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    disableTAMIC()
    var constraints = [NSLayoutConstraint]()
    if value > 0 {
      constraints.append(widthAnchor.constraint(equalToConstant: value))
      constraints.append(heightAnchor.constraint(equalToConstant: value))
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
}

extension UIView {
  
  var tAMIC: Bool {
    get { translatesAutoresizingMaskIntoConstraints }
    set { translatesAutoresizingMaskIntoConstraints = newValue }
  }
  
  func disableTAMIC() {
    tAMIC = false
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
  
  func pinToSuperviewSafeAreaHorizontalEdges(defaultSpacing: CGFloat = 0, trailingSpacing: CGFloat? = nil) {
    guard let superview = superview else { return }
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: defaultSpacing),
      trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -(trailingSpacing ?? defaultSpacing))
    ])
  }

}
