//
// MatchView.swift
// Tinder
//
// Created by Gin Imor on 4/15/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

protocol MatchViewDelegate: AnyObject {
  func didTappedSendMessageButton(match: Match, currUid: String)
}

class MatchView: UIView {
  
  private static let imageWidth: CGFloat = 140
  
  weak var delegate: MatchViewDelegate?
  
  private let match: Match
  private let matchedUser: CardModel
  private let currentUser: CardModel
  
  private var container: UIStackView!
  
  private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
  
  private let matchTitleImageView = UIImageView.new(imageName: "itsamatch", cornerRadius: 0)
  private let messageLabel = UILabel.new("", .body, .white, .center)
  private let currentUserImageView = newUserImageView()
  private let matchedUserImageView = newUserImageView()
  
  private let sendMessageButton: UIButton = {
    let button = GradientButton()
    button.setTitle("SEND MESSAGE", for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let keepSwipingButton: UIButton = {
    let button = BorderGradientButton()
    button.setTitle("Keep Swiping", for: .normal)
    button.setTitleColor(.black, for: .normal)
    return button
  }()
  
  private let dispatchGroup = DispatchGroup()
  
  private static func newUserImageView() -> UIImageView {
    let imageView = UIImageView.new(imageName: "", cornerRadius: imageWidth / 2)
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.layer.borderWidth = 2
    return imageView
  }
  
  public init(match: Match, matchedUser: CardModel, currentUser: CardModel) {
    self.match = match
    self.matchedUser = matchedUser
    self.currentUser = currentUser
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    addActions()
    setupLayout()
    fetchImages()
  }
  
  private func addActions() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
    sendMessageButton.addTarget(self, action: #selector(handleSendMessage))
    keepSwipingButton.addTarget(self, action: #selector(handleDismiss))
  }
  
  private func setupLayout() {
    blurView.add(to: self).filling(self)
    
    let userImageStackView = hStack(currentUserImageView, matchedUserImageView)
      .distributing(.fillEqually).spacing(16)

    container = vStack(
      matchTitleImageView, messageLabel, userImageStackView,
      vStack(sendMessageButton, keepSwipingButton)
        .distributing(.fillEqually).spacing(16)
    )
      
    container.alpha = 0.0
    container.setCustomSpacing(16, after: userImageStackView)
    container.add(to: self).centering()
    
    messageLabel.text = "You and \(matchedUser.displayName) have liked each other"
    
    matchTitleImageView.sizing(height: 80)
    messageLabel.sizing(height: 50)
    // this constraint determine the container's width, cause doesn't have room
    // for userImageStackView to change it's width
    currentUserImageView.sizing(to: MatchView.imageWidth)
    // this constraint determine the keepSwipingButton's height too, cause
    // the vStack fillEqually distribution
    sendMessageButton.sizing(height: 50)
  }
  
  private func fetchImages() {
    guard let currentUserImageUrl = currentUser.validImageUrls.first,
          let matchedUserImageUrl = matchedUser.validImageUrls.first else { return }
    currentUserImageView.sd_setImageSync(with: currentUserImageUrl, dispatchGroup: dispatchGroup)
    matchedUserImageView.sd_setImageSync(with: matchedUserImageUrl, dispatchGroup: dispatchGroup)
    // wait until two image view get their images, set up the animations
    dispatchGroup.notify(queue: .main) { [weak self] in self?.setupAnimations() }
  }
  
  private func setupAnimations() {
    // image views animation
    currentUserImageView.transform = startTransform(forLeftUser: true)
    matchedUserImageView.transform = startTransform(forLeftUser: false)
    UIView.animateKeyframes(withDuration: 1.3, delay: 0.0) {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.2) {
        self.container.alpha = 1.0
      }
      UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.5) {
        self.currentUserImageView.transform = self.secondEndTransform(forLeftUser: true)
        self.matchedUserImageView.transform = self.secondEndTransform(forLeftUser: false)
      }
      UIView.addKeyframe(withRelativeStartTime: 0.55, relativeDuration: 0.45) {
        self.currentUserImageView.transform = .identity
        self.matchedUserImageView.transform = .identity
      }
    }
    // buttons animation, start at image views animation total time * 0.6
    sendMessageButton.transform = startTransform(forTopButton: true)
    keepSwipingButton.transform = startTransform(forTopButton: false)
    UIView.animate(withDuration: 0.6, delay: 1.3 * 0.6, usingSpringWithDamping: 0.5
      , initialSpringVelocity: 0.1) {
      self.sendMessageButton.transform = .identity
      self.keepSwipingButton.transform = .identity
    }
  }
  
  private func startTransform(forLeftUser: Bool) -> CGAffineTransform {
    let sign: CGFloat = forLeftUser ? 1 : -1
    let moveBy = CGAffineTransform(translationX: sign * 200, y: 0)
    return moveBy.rotated(by: -sign * CGFloat.pi / 6)
  }
  
  private func secondEndTransform(forLeftUser: Bool) -> CGAffineTransform {
    let sign: CGFloat = forLeftUser ? 1 : -1
    return CGAffineTransform(rotationAngle: -sign * CGFloat.pi / 6)
  }
  
  private func startTransform(forTopButton: Bool) -> CGAffineTransform {
    let sign: CGFloat = forTopButton ? 1 : -1
    return CGAffineTransform(translationX: -sign * UIScreen.main.bounds.width, y: 0)
  }
  
  @objc private func handleSendMessage() {
    delegate?.didTappedSendMessageButton(match: match, currUid: currentUser.uid)
    removeFromSuperview()
  }
  
  @objc private func handleDismiss() {
    UIView.animate(
      withDuration: 0.5,
      delay: 0.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 1.0) {
      self.alpha = 0.0
    } completion: { _ in
      self.alpha = 1.0
      self.removeFromSuperview()
    }
  }
  
}
