//
// MatchView.swift
// Tinder
//
// Created by Gin Imor on 4/15/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MatchView: UIView {
  
  private let matchedUser: CardModel
  private let currentUser: CardModel
  
  private var container: UIStackView!
  
  private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
  
  private let matchTitleImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage(named: "itsamatch"))
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.preferredFont(forTextStyle: .body)
    label.textColor = .white
    label.textAlignment = .center
    return label
  }()
  private let currentUserImageView = newUserImageView(image: UIImage(named: "ross"))
  private let matchedUserImageView = newUserImageView(image: UIImage(named: "joey"))
  
  private let sendMessageButton: UIButton = {
    let button = GradientButton()
    button.setTitle("SEND MESSAGE", for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private let keepSwipingButton: UIButton = {
    let button = BorderGradientButton()
    button.setTitle("Keep Swiping", for: .normal)
    button.setTitleColor(.white, for: .normal)
    return button
  }()
  
  private static var imageWidth: CGFloat { 140 }
  
  private let dispatchGroup = DispatchGroup()
  
  private static func newUserImageView(image: UIImage?) -> UIImageView {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.borderColor = UIColor.white.cgColor
    imageView.layer.borderWidth = 2
    imageView.layer.cornerRadius = imageWidth / 2
    return imageView
  }
  
  public init(matchedUser: CardModel, currentUser: CardModel) {
    self.matchedUser = matchedUser
    self.currentUser = currentUser
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    addGestureRecognizer()
    setupLayout()
    fetchImages()
  }
  
  private func fetchImages() {
    guard let currentUserImageUrl = currentUser.validImageUrls.first,
          let matchedUserImageUrl = matchedUser.validImageUrls.first else { return }
    currentUserImageView.sd_setImageSync(with: currentUserImageUrl, dispatchGroup: dispatchGroup)
    matchedUserImageView.sd_setImageSync(with: matchedUserImageUrl, dispatchGroup: dispatchGroup)
    dispatchGroup.notify(queue: .main) { [weak self] in
      self?.setupAnimations()
    }
  }
  
  private func setupAnimations() {
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
    
    sendMessageButton.transform = startTransform(forTopButton: true)
    keepSwipingButton.transform = startTransform(forTopButton: false)
    UIView.animate(withDuration: 0.6, delay: 1.3 * 0.6, usingSpringWithDamping: 0.5
      , initialSpringVelocity: 0.1) {
      self.sendMessageButton.transform = .identity
      self.keepSwipingButton.transform = .identity
    }
  }
  
  private func secondEndTransform(forLeftUser: Bool) -> CGAffineTransform {
    let sign: CGFloat = forLeftUser ? 1 : -1
    return CGAffineTransform(rotationAngle: -sign * CGFloat.pi / 6)
  }
  
  private func startTransform(forTopButton: Bool) -> CGAffineTransform {
    let sign: CGFloat = forTopButton ? 1 : -1
    return CGAffineTransform(translationX: -sign * UIScreen.main.bounds.width, y: 0)
  }
  
  private func startTransform(forLeftUser: Bool) -> CGAffineTransform {
    let sign: CGFloat = forLeftUser ? 1 : -1
    let moveBy = CGAffineTransform(translationX: sign * 200, y: 0)
    return moveBy.rotated(by: -sign * CGFloat.pi / 6)
  }
  
  private func addGestureRecognizer() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
  }
  
  private func setupLayout() {
    blurView.pinToSuperviewEdges(pinnedView: self)
    
    let userImagesStackView = UIStackView(arrangedSubviews: [currentUserImageView, matchedUserImageView])
    userImagesStackView.distribution = .fillEqually
    userImagesStackView.spacing = 16
    
    let buttonsStackView = UIStackView.verticalStack(arrangedSubviews: [sendMessageButton, keepSwipingButton])
    buttonsStackView.distribution = .fillEqually
    buttonsStackView.spacing = 16
    
    container = UIStackView.verticalStack(arrangedSubviews: [matchTitleImageView, messageLabel,
                                                                 userImagesStackView, buttonsStackView])
    container.alpha = 0.0
    container.setCustomSpacing(16, after: userImagesStackView)
    container.centerToSuperviewSafeAreaLayoutGuide(superview: self)
    
    messageLabel.text = "You and \(matchedUser.displayName) have liked each other"
    
    matchTitleImageView.setSize(CGSize(height: 80))
    messageLabel.setSize(CGSize(height: 50))
    currentUserImageView.setSize(CGSize(widthHeight: MatchView.imageWidth))
    sendMessageButton.setSize(CGSize(height: 50))
  }
  
  @objc func handleDismiss() {
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0
      , initialSpringVelocity: 1.0, animations: {
      self.alpha = 0.0
    }, completion: { _ in
      self.alpha = 1.0
      self.removeFromSuperview()
    })
  }
  
}
