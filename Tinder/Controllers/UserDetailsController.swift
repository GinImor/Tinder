//
// UserDetailsController.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class UserDetailsController: UIViewController {
  
  let scrollView =  UIScrollView()
  let infoLabel = UILabel()
  let dismissButton = UIButton(type: .system)
  lazy var dislikeButton = newButtonControl(image: UIImage(systemName: "multiply.circle"), selector: #selector
  (dislike), tintColor: .red, pointSize: 44)
  lazy var likeButton = newButtonControl(image: UIImage(systemName: "star.circle"), selector: #selector(dislike),
    tintColor: .blue, pointSize: 30)
  lazy var superLikeButton = newButtonControl(image: UIImage(systemName: "heart.circle"), selector: #selector
  (dislike), tintColor: .green, pointSize: 44)
  
  public var cardViewModel: CardViewModel! {
    didSet {
      swipingPhotosController.cardViewModel = cardViewModel
      infoLabel.attributedText = cardViewModel.attributedString
      infoLabel.textAlignment = cardViewModel.textAlignment
    }
  }
  
  private var swipingView: UIView {
    swipingPhotosController.view
  }
  
  private let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: 
  .horizontal)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  private func setupViews() {
    setupView()
    setupScrollView()
    setupSwipingView()
    setupInfoLabel()
    setupDismissButton()
    setupBottomControls()
  }
  
  private func setupBottomControls() {
    let stackView = UIStackView(arrangedSubviews: [dislikeButton, likeButton, superLikeButton])
    stackView.spacing = 32
    stackView.disableTAMIC()
    scrollView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
    ])
  }
  
  private func setupDismissButton() {
    dismissButton.disableTAMIC()
    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 33)
    let image = UIImage(systemName: "arrow.down.circle.fill")?.withConfiguration(symbolConfiguration)
    dismissButton.setImage(image, for: .normal)
    dismissButton.tintColor = .red
    scrollView.addSubview(dismissButton)
    NSLayoutConstraint.activate([
      dismissButton.centerYAnchor.constraint(equalTo: swipingView.bottomAnchor),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: dismissButton.trailingAnchor, multiplier: 2.0),
    ])
    dismissButton.addTarget(self, action: #selector(performDismiss), for: .touchUpInside)
  }
  
  @objc func performDismiss() {
    cardViewModel.switchScenario()
    dismiss(animated: true)
  }
  
  private func setupView() {
    view.backgroundColor = .white
  }
  
  private func setupSwipingView() {
    addChild(swipingPhotosController)
    scrollView.addSubview(swipingView)
    swipingPhotosController.didMove(toParent: self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let width = view.bounds.width
    let rect = CGRect(x: 0, y: 0, width: width, height: width)
    if swipingView.frame != rect {
      swipingView.frame = rect
    }
  }
  
  private func setupInfoLabel() {
    infoLabel.numberOfLines = 0
    infoLabel.disableTAMIC()
    scrollView.addSubview(infoLabel)
    NSLayoutConstraint.activate([
      infoLabel.topAnchor.constraint(equalTo: swipingView.bottomAnchor, constant: 16),
      infoLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
      infoLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16)
    ])
  }
  
  @objc func dislike() {
    print("dislike")
  }
  
  private func setupScrollView() {
    scrollView.delegate = self
    scrollView.alwaysBounceVertical = true
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.pinToSuperviewEdges(pinnedView: view)
  }
  
  private func newButtonControl(image: UIImage?, selector: Selector, tintColor: UIColor, pointSize: CGFloat) ->
  UIButton {
    let button = UIButton(type: .system)
    button.tintColor = tintColor
    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize)
    button.setImage(image?.withConfiguration(symbolConfiguration), for: .normal)
    button.addTarget(self, action: selector, for: .touchUpInside)
    return button
  }
}

extension UserDetailsController: UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let contentOffsetY = scrollView.contentOffset.y
    guard contentOffsetY <= 0 else { return }
    let swipingViewWidth = scrollView.bounds.width - 2 * contentOffsetY
    swipingView.frame = CGRect(x: contentOffsetY, y: contentOffsetY, width: swipingViewWidth, height: swipingViewWidth)
  }
}
