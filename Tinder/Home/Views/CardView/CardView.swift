//
//  CardView.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

protocol CardViewDelegate: AnyObject {
  func didTappedDetailArea(_: CardView)
  func willSwipeCard(_: CardView, toRight: Bool)
  func didFinishedSwipingCard(_: CardView)
}

class CardView: UIView {
  
  weak var delegate: CardViewDelegate?
  
  var uid: String { cardViewModel.uid }
  
  var cardViewModel: CardViewModel! {
    didSet {
      guard let cardViewModel = cardViewModel else { return }
      swipingPhotosController.cardViewModel = cardViewModel
      contentView.informationLabel.attributedText = cardViewModel.attributedString
      contentView.informationLabel.textAlignment = cardViewModel.textAlignment
    }
  }

  var contentView = UINib.viewWithName("CardContentView") as! CardContentView

  private var swipingView: UIView { swipingPhotosController.view }
  private let swipingPhotosController = SwipingPhotosController()


  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:))))
    // use the root view as a shell to protect contentView from being distorted because of
    // transform rotation applied to the card view, the contentView inset from the root view
    // by 2.5
    layer.borderWidth = 3
    layer.borderColor = UIColor.clear.cgColor
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    layer.allowsEdgeAntialiasing = true
    swipingView.add(to: contentView).filling(contentView)
    contentView.roundedCorner(8).sendSubviewToBack(swipingView)
    contentView.add(to: self).filling(self, edgeInsets: .init(2.5))
    contentView.didTappedDetailArea = { [unowned self] in
      self.delegate?.didTappedDetailArea(self)
    }
  }
  
  func prepareForReuse() {
    swipingPhotosController.prepareForReuse()
  }
  
  // during swiping, only transform changed, and when the animation completed
  // it'll be set to identity
  func swipeToRight(_ right: Bool) {
    animateSwiping(CGPoint(x: frame.width * 1.5 * (right ? 1 : -1), y: 0.0))
  }
  
  @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
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
    let threshold: CGFloat = 50
    let translation = pan.translation(in: superview)
    
    if abs(translation.x) > threshold {
      let ratio = translation.y / translation.x
      let finalTransitionX = frame.width * 1.5 * (translation.x > 0 ? 1 : -1)
      let finalTransitionY = finalTransitionX * ratio
      let finalTransition = CGPoint(x: finalTransitionX, y: finalTransitionY)
      delegate?.willSwipeCard(self, toRight: translation.x > 0)
      animateSwiping(finalTransition)
    } else {
      animateBouncingBack()
    }
  }
  
  private func animateSwiping(_ transition: CGPoint) {
    UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: []) {
      self.transform = self.transform(for: transition)
    } completion: { (_) in
      self.transform = .identity
      self.delegate?.didFinishedSwipingCard(self)
    }
  }
  
  private func animateBouncingBack() {
    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: []) {
      self.transform = .identity
    }
  }
  
  private func transform(for translation: CGPoint) -> CGAffineTransform {
    let moveBy = CGAffineTransform(translationX: translation.x, y: translation.y)
    let rotation = -sin(translation.x / (frame.width * 4.0))
    return moveBy.rotated(by: rotation)
  }
  
}
