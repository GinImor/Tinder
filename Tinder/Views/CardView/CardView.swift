//
//  CardView.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import SDWebImage

class CardView: UIView {
  
  let gradientLayer = CAGradientLayer()
  var imageNames: [String] = []
  
  @IBOutlet weak var imageView: UIImageView!
  
  @IBOutlet weak var informationLabel: UILabel!  {
    didSet {
      gradientLayer.colors = [UIColor.clear, .black].map { $0.cgColor }
      gradientLayer.locations = [0.0, 3.0]
      layer.insertSublayer(gradientLayer, below: informationLabel.layer)
    }
  }
  
  @IBOutlet weak var barIndicators: UIStackView!
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    backgroundColor = .white
    layer.cornerRadius = 8
    layer.masksToBounds = true
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
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
  
  private var barDefaultColor = UIColor(white: 0.0, alpha: 0.1)
  private var imageIndex = 0
  
  func setImageNames(_ imageNames: [String]) {
    guard !imageNames.isEmpty else { return }
    
    self.imageNames = imageNames
    let firstImageName = imageNames[0]
    imageView.sd_setImage(with: URL(string: firstImageName))
    
    guard imageNames.count > 1 else { return }
    barIndicators.isHidden = false
    (0..<imageNames.count).forEach { (_) in
      let barIndicator = UIView()
      barIndicator.backgroundColor = barDefaultColor
      barIndicators.addArrangedSubview(barIndicator)
    }
    barIndicators.arrangedSubviews[0].backgroundColor = .white
  }
  
  private func advanceImageIndex(byStep step: Int) -> Int {
    ((imageIndex + step) % imageNames.count + imageNames.count) % imageNames.count
  }
  
  @objc func handleTap(_ tap: UITapGestureRecognizer) {
    guard !barIndicators.isHidden else { return }
    barIndicators.arrangedSubviews[imageIndex].backgroundColor = barDefaultColor
    let location = tap.location(in: self)
    if location.x > bounds.width / 2 {
      imageIndex = advanceImageIndex(byStep: 1)
    } else {
      imageIndex = advanceImageIndex(byStep: -1)
    }
    barIndicators.arrangedSubviews[imageIndex].backgroundColor = .white
    imageView.sd_setImage(with: URL(string: imageNames[imageIndex]))
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
