//
//  HomeView.swift
//  Tinder
//
//  Created by Gin Imor on 3/21/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class HomeView: UIView {
  
  @IBOutlet weak var topStackView: UIStackView! {
    didSet {
      topStackView.isLayoutMarginsRelativeArrangement = true
      topStackView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
  }
  
  @IBOutlet weak var cardView: UIView! {
    didSet {
      cardView.layer.zPosition = 10
      cardView.layer.cornerRadius = ceil(cardView.bounds.width * 0.05)
      cardView.layer.masksToBounds = true
      cardView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    }
  }

  private func transform(for translation: CGPoint) -> CGAffineTransform {
    let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
    let rotation = -sin(translation.x / (cardView.frame.width * 4.0))
    return moveBy.rotated(by: rotation)
  }
  
  @objc func handlePan(_ pan: UIPanGestureRecognizer) {
    switch pan.state {
    case .changed:
      let translation = pan.translation(in: self)
      cardView.transform = transform(for: translation)
    case .ended:
      handlePanEnded(pan)
    default: ()
    }
  }
  
  private func handlePanEnded(_ pan: UIPanGestureRecognizer) {
    let threshold = cardView.frame.width * 0.4
    let translation = pan.translation(in: self)
    
    if abs(translation.x) > threshold {
      let ratio = translation.y / translation.x
      let finalX = cardView.frame.width * 2.0 * (translation.x > 0 ? 1 : -1)
      let finalY = finalX * ratio
      let finalPoint = CGPoint(
        x: finalX,
        y: finalY)
      
      UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
        self.cardView.transform = self.transform(for: finalPoint)
      }) { (_) in
        self.cardView.transform = .identity
      }
    } else {
      UIView.animate(
        withDuration: 0.5,
        delay: 0.0,
        usingSpringWithDamping: 0.4,
        initialSpringVelocity: 0.1,
        options: [],
        animations: {
          self.cardView.transform = .identity
      },
        completion: nil
      )
    }
  }
}
