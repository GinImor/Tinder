//
//  CardView.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate: class {
  func didTappedDetailButton(_: CardViewModel)
  func willSwipeCard(_: CardView, toRight: Bool)
}

class CardView: UIView {
  
  let gradientLayer = CAGradientLayer()
    
  @IBOutlet weak var informationContainerView: UIView! {
    didSet {
      gradientLayer.colors = [UIColor.clear, .black].map { $0.cgColor }
      gradientLayer.locations = [0.0, 1.3]
      layer.insertSublayer(gradientLayer, below: informationContainerView.layer)
    }
  }
  
  @IBOutlet weak var informationLabel: UILabel!
  
  weak var delegate: CardViewDelegate?
  
  public var cardViewModel: CardViewModel? {
    didSet {
      guard let cardViewModel = cardViewModel else { return }
      swipingPhotosController.cardViewModel = cardViewModel
      informationLabel.attributedText = cardViewModel.attributedString
      informationLabel.textAlignment = cardViewModel.textAlignment
    }
  }
  
  private let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation:
  .horizontal)
  
  private var swipingView: UIView {
    swipingPhotosController.view
  }
  
  public var uid: String { cardViewModel?.uid ?? "" }
  
  @IBAction func didTappedDetailButton(_ sender: Any) {
    guard let viewModel = cardViewModel else { return }
    delegate?.didTappedDetailButton(viewModel)
  }
    
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  private func setup() {
    backgroundColor = .white
    layer.cornerRadius = 8
    layer.masksToBounds = true
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    swipingView.pinToSuperviewEdges(pinnedView: self)
    sendSubviewToBack(swipingView)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = CGRect(
      x: informationContainerView.frame.minX - 8,
      y: informationContainerView.frame.minY,
      width: informationContainerView.frame.width + 16,
      height: informationContainerView.frame.height + 8
    )
  }
  
  private func transform(for translation: CGPoint) -> CGAffineTransform {
    let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
    let rotation = -sin(translation.x / (frame.width * 4.0))
    return moveBy.rotated(by: rotation)
  }
  
  func swipeToRight(_ right: Bool) {
    transform = transform(for: CGPoint(x: frame.width * 2.0 * (right ? 1 : -1), y: 0.0))
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
      delegate?.willSwipeCard(self, toRight: translation.x > 0)
      UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
          self.transform = self.transform(for: finalPoint)
      }) { (_) in
        self.transform = .identity
        self.removeFromSuperview()
      }
    } else {
      UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options:
      [], animations: {
          self.transform = .identity
      },
        completion: nil
      )
    }
  }
  
}
