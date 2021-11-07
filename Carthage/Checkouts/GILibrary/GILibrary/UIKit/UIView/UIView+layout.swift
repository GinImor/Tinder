//
//  UIView+layout.swift
//  GILibrary
//
//  Created by Gin Imor on 1/31/21.
//
//

import UIKit

public protocol AnchorObject: class {
  var defaultAnchoredView: UIView? {get}
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
}

extension UIView: AnchorObject {
  public var defaultAnchoredView: UIView? { superview }
}
extension UILayoutGuide: AnchorObject {
  public var defaultAnchoredView: UIView? { owningView }
}

public enum HorizontalAnchor {
  case leading, trailing, centerX
}

public enum VerticalAnchor {
  case top, bottom, centerY
}

public enum BaselineAnchor {
  case first, last
}

public enum SizeAnchor {
  case width, height
}

public extension NSLayoutConstraint {
  
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

public extension UIView {
  
  convenience init(backgroundColor: UIColor) {
    self.init()
    self.backgroundColor = backgroundColor
  }
  
  @discardableResult
  func disableTAMIC() -> Self {
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  
  @discardableResult
  func add(to view: UIView) -> Self {
    view.addSubview(self)
    translatesAutoresizingMaskIntoConstraints = false
    return self
  }
  
  @discardableResult
  func withCH(_ CH: Float, CR: Float, axis: NSLayoutConstraint.Axis) -> Self {
    setContentHuggingPriority(UILayoutPriority(rawValue: CH), for: axis)
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: CR), for: axis)
    return self
  }
  
  @discardableResult
  func withCH(_ priority: Float, axis: NSLayoutConstraint.Axis) -> Self {
    setContentHuggingPriority(UILayoutPriority(rawValue: priority), for: axis)
    return self
  }
  
  @discardableResult
  func withCR(_ priority: Float, axis: NSLayoutConstraint.Axis) -> Self {
    setContentCompressionResistancePriority(UILayoutPriority(rawValue: priority), for: axis)
    return self
  }
  
  @discardableResult
  func baselining(
    _ anchor: BaselineAnchor,
    to linedObject: UIView,
    _ linedAnchor: BaselineAnchor? = nil,
    value: CGFloat = 0,
    constraintHandler: ((NSLayoutConstraint) -> Void)? = nil
  ) -> Self {
    let firstItemAnchor = anchor == .first ? firstBaselineAnchor : lastBaselineAnchor
    let secondItemAnchor = (linedAnchor ?? anchor) == .first ?
      linedObject.firstBaselineAnchor : linedObject.lastBaselineAnchor
    let constraint = firstItemAnchor.constraint(equalTo: secondItemAnchor, constant: value)
    constraint.isActive = true
    constraintHandler?(constraint)
    return self
  }
  
}

public extension AnchorObject {
  
  @discardableResult
  func hLining(
    to linedObject: AnchorObject? = nil,
    edgeInsets: UIEdgeInsets = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _linedObject = linedObject ?? potentialAnchoredObject else { return self }
    let constraints = [
      leadingAnchor.constraint(equalTo: _linedObject.leadingAnchor, constant: edgeInsets.left),
      trailingAnchor.constraint(equalTo: _linedObject.trailingAnchor, constant: -edgeInsets.right)
    ]
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  @discardableResult
  func hLining(
    _ anchor: HorizontalAnchor,
    to linedObject: AnchorObject? = nil,
    _ linedAnchor: HorizontalAnchor? = nil,
    value: CGFloat = 0,
    constraintHandler: ((NSLayoutConstraint) -> Void)? = nil
  ) -> Self {
    guard let _linedObject = linedObject ?? potentialAnchoredObject else { return self }
    let _linedAnchor = linedAnchor ?? anchor
    let firstItemAnchor = anchor == .leading ? leadingAnchor :
      (anchor == .trailing ? trailingAnchor : centerXAnchor)
    let secondItemAnchor = _linedAnchor == .leading ? _linedObject.leadingAnchor :
      (_linedAnchor == .trailing ? _linedObject.trailingAnchor : _linedObject.centerXAnchor)
    let constraint = firstItemAnchor.constraint(equalTo: secondItemAnchor, constant: value)
    constraint.isActive = true
    constraintHandler?(constraint)
    return self
  }

  @discardableResult
  func vLining(
    to linedObject: AnchorObject? = nil,
    edgeInsets: UIEdgeInsets = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _linedObject = linedObject ?? potentialAnchoredObject else { return self }
    let constraints = [
      topAnchor.constraint(equalTo: _linedObject.topAnchor, constant: edgeInsets.top),
      bottomAnchor.constraint(equalTo: _linedObject.bottomAnchor, constant: -edgeInsets.bottom)
    ]
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
    constraintHandler: ((NSLayoutConstraint) -> Void)? = nil
  ) -> Self {
    guard let _linedObject = linedObject ?? potentialAnchoredObject else { return self }
    let _linedAnchor = linedAnchor ?? anchor
    let firstItemAnchor = anchor == .top ? topAnchor :
      (anchor == .bottom ? bottomAnchor : centerYAnchor)
    let secondItemAnchor = _linedAnchor == .top ? _linedObject.topAnchor :
      (_linedAnchor == .bottom ? _linedObject.bottomAnchor : _linedObject.centerYAnchor)
    let constraint = firstItemAnchor.constraint(equalTo: secondItemAnchor, constant: value)
    constraint.isActive = true
    constraintHandler?(constraint)
    return self
  }

  @discardableResult
  func filling(
    _ filledObject: AnchorObject? = nil,
    edgeInsets: UIEdgeInsets = .zero,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
    guard let _filledObject = filledObject ?? potentialAnchoredObject else { return self }
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
    guard let _centeredObject = centeredObject ?? potentialAnchoredObject else { return self }
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
    guard let _sizedObject = sizedObject ?? potentialAnchoredObject else { return self }
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
    _ sizedAnchor: SizeAnchor? = nil,
    multiplier: CGFloat = 1.0,
    delta: CGFloat = 0,
    constraintHandler: ((NSLayoutConstraint) -> Void)? = nil
  ) -> Self {
    guard let _sizedObject = sizedObject ?? potentialAnchoredObject else { return self }
    let firstItemAnchor = anchor == .width ? widthAnchor : heightAnchor
    let secondItemAnchor = (sizedAnchor ?? anchor) == .width ? _sizedObject.widthAnchor : _sizedObject.heightAnchor
    let constraint = firstItemAnchor.constraint(equalTo: secondItemAnchor, multiplier: multiplier, constant: delta)
    constraint.isActive = true
    constraintHandler?(constraint)
    return self
  }
  
  @discardableResult
  func sizing(
    width: CGFloat = 0,
    height: CGFloat = 0,
    constraintsHandler: (([NSLayoutConstraint]) -> Void)? = nil
  ) -> Self {
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
    var constraints = [NSLayoutConstraint]()
    if value > 0 {
      constraints.append(widthAnchor.constraint(equalToConstant: value))
      constraints.append(heightAnchor.constraint(equalToConstant: value))
    }
    NSLayoutConstraint.activate(constraints)
    constraintsHandler?(constraints)
    return self
  }
  
  private var potentialAnchoredObject: AnchorObject? {
    if #available(iOS 11.0, *) {
      return defaultAnchoredView?.safeAreaLayoutGuide
    } else {
      return defaultAnchoredView
    }
  }
  
}
