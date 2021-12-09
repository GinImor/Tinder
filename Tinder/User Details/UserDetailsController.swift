//
// UserDetailsController.swift
// Tinder
//
// Created by Gin Imor on 4/12/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

protocol UserDetailsControllerDelegate: AnyObject {
  func didTappedDislikeButton()
  func didTappedLikeButton()
  func didTappedSuperLikeButton()
}

class UserDetailsController: UIViewController {
  
  weak var delegate: UserDetailsControllerDelegate?
  
  private let scrollView =  UIScrollView()
  private let infoLabel = UILabel()
  private let bioLabel = UILabel()
  private let dismissButton = UIButton(type: .system)
  
  private lazy var dislikeButton = newButtonControl(
    image: UIImage(systemName: "multiply.circle.fill"),
    selector: #selector (dislike), tintColor: .red, pointSize: 44)
  
  private lazy var superLikeButton = newButtonControl(
    image: UIImage(systemName: "star.circle.fill"),
    selector: #selector(superLike), tintColor: .blue, pointSize: 30)
  
  private lazy var likeButton = newButtonControl(
    image: UIImage(systemName: "heart.circle.fill"),
    selector: #selector(like), tintColor: .green, pointSize: 44)
  
  var cardViewModel: CardViewModel! {
    didSet {
      swipingPhotosController.cardViewModel = cardViewModel
      infoLabel.attributedText = cardViewModel.attributedString
      infoLabel.textAlignment = cardViewModel.textAlignment
      bioLabel.attributedText = cardViewModel.introduction
    }
  }
  
  private var swipingView: UIView {
    swipingPhotosController.view
  }
  
  private let swipingPhotosController =
    SwipingPhotosController()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    // at this time, view can get its correct size
    let width = view.bounds.width
    let rect = CGRect(x: 0, y: 0, width: width, height: width)
    if swipingView.frame != rect {
      swipingView.frame = rect
    }
  }
  
  private func setupViews() {
    setupView()
    setupScrollView()
    setupSwipingView()
    setupInfoLabel()
    setupBioLabel()
    setupDismissButton()
    setupBottomControls()
  }
  
  private func setupView() {
    view.backgroundColor = .white
  }

  private func setupScrollView() {
    scrollView.delegate = self
    scrollView.alwaysBounceVertical = true
    scrollView.showsVerticalScrollIndicator = false
    scrollView.contentInsetAdjustmentBehavior = .never
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
  }
  
  private func setupSwipingView() {
    addChild(swipingPhotosController)
    scrollView.addSubview(swipingView)
    swipingPhotosController.didMove(toParent: self)
  }
  
  private func setupInfoLabel() {
    infoLabel.numberOfLines = 0
    infoLabel.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(infoLabel)
    NSLayoutConstraint.activate([
      infoLabel.topAnchor.constraint(equalTo: swipingView.bottomAnchor, constant: 16),
      infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
    ])
  }
  
  private func setupBioLabel() {
    bioLabel.numberOfLines = 0
    bioLabel.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(bioLabel)
    NSLayoutConstraint.activate([
      bioLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 8),
      bioLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      bioLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    ])
  }
  
  private func setupDismissButton() {
    dismissButton.translatesAutoresizingMaskIntoConstraints = false
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


  private func setupBottomControls() {
    let shadow = UIView()
    shadow.backgroundColor = .white
    shadow.translatesAutoresizingMaskIntoConstraints = false
    shadow.layer.shadowOpacity = 1.0
    shadow.layer.shadowColor = UIColor.white.cgColor
    shadow.layer.shadowRadius = 20.0
    shadow.layer.shadowOffset = CGSize(width: 0, height: -10)
    shadow.layer.shouldRasterize = true
    view.addSubview(shadow)

    let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
    stackView.spacing = 32
    stackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(stackView)
    
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(spacer)

    NSLayoutConstraint.activate([
      shadow.topAnchor.constraint(equalTo: stackView.centerYAnchor),
      shadow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      shadow.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      shadow.trailingAnchor.constraint(equalTo: view.trailingAnchor),

      stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
      
      spacer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      spacer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      spacer.heightAnchor.constraint(equalTo: stackView.heightAnchor),
      spacer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
      spacer.topAnchor.constraint(greaterThanOrEqualTo: bioLabel.bottomAnchor)
    ])
  }
  
  // target action has certain signatures, can't use _performDismiss directly
  @objc private func performDismiss() {
    _performDismiss()
  }
  
  @objc private func dislike() {
    _performDismiss { [weak self] in self?.delegate?.didTappedDislikeButton() }
  }
  
  @objc private func like() {
    _performDismiss { [weak self] in self?.delegate?.didTappedLikeButton() }
  }
  
  @objc private func superLike() {
    _performDismiss { [weak self] in self?.delegate?.didTappedSuperLikeButton() }
  }
  
  private func _performDismiss(completion: (() -> Void)? = nil) {
    dismiss(animated: true) { [weak self] in
      self?.scrollView.contentOffset = .zero
      self?.swipingPhotosController.prepareForReuse()
      self?.cardViewModel.switchScenario()
      completion?()
    }
  }
  
  private func newButtonControl(image: UIImage?, selector: Selector,
                                tintColor: UIColor, pointSize: CGFloat) -> UIButton {
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
    let swipingViewWidth = scrollView.bounds.width - contentOffsetY
    swipingView.frame = CGRect(
      x: contentOffsetY / 2,
      y: contentOffsetY,
      width: swipingViewWidth,
      height: swipingViewWidth)
  }
}
