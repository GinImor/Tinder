//
//  CardView.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CardView: UIView {
  
  let gradientLayer = CAGradientLayer()
  
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var informationLabel: UILabel!  {
    didSet {
      gradientLayer.colors = [UIColor.clear, .black].map { $0.cgColor }
      gradientLayer.locations = [0.0, 3.0]
      layer.insertSublayer(gradientLayer, below: informationLabel.layer)
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = CGRect(
      x: informationLabel.frame.minX - 8,
      y: informationLabel.frame.minY,
      width: informationLabel.frame.width + 16,
      height: informationLabel.frame.height + 8
    )
  }
  
  func addCornerEffect() {
    layer.cornerRadius = ceil(bounds.width * 0.05)
    layer.masksToBounds = true
  }
  
  private func transform(for translation: CGPoint) -> CGAffineTransform {
    let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
    let rotation = -sin(translation.x / (frame.width * 4.0))
    return moveBy.rotated(by: rotation)
  }
  
  @objc func handlePan(_ pan: UIPanGestureRecognizer) {
    switch pan.state {
    case .changed:
      let translation = pan.translation(in: self)
      transform = transform(for: translation)
    case .ended:
      handlePanEnded(pan)
    default: ()
    }
  }
  
  private func handlePanEnded(_ pan: UIPanGestureRecognizer) {
    let threshold = frame.width * 0.3
    let translation = pan.translation(in: superview)
    
    if abs(translation.x) > threshold {
      let ratio = translation.y / translation.x
      let finalX = frame.width * 2.0 * (translation.x > 0 ? 1 : -1)
      let finalY = finalX * ratio
      let finalPoint = CGPoint( x: finalX, y: finalY)
      
      UIView.animate(
        withDuration: 0.5,
        delay: 0.0,
        options: .curveEaseIn,
        animations: {
          self.transform = self.transform(for: finalPoint)
      }) { (_) in
        self.transform = .identity
        self.removeFromSuperview()
      }
    } else {
      UIView.animate(
        withDuration: 0.5,
        delay: 0.0,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 0.1,
        options: [],
        animations: {
          self.transform = .identity
      },
        completion: nil
      )
    }
  }
  
}
