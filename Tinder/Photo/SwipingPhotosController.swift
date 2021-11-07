//
// SwipingPhotosController.swift
// Tinder
//
// Created by Gin Imor on 4/14/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class SwipingPhotosController: UIPageViewController {
  
  private var controllers = (0..<3).map {
    page -> PhotoController in
    let photoController = PhotoController()
    photoController.page = page
    return photoController
  }
  
  private let barIndicators = UIStackView()

  private var _transitionInProgress = false

  var cardViewModel: CardViewModel! {
    didSet {
      (0..<cardViewModel.urlsCount).forEach { controllers[$0].imageUrlString = cardViewModel.imageUrls[$0] }
      setViewControllers([controllers[cardViewModel.currentImageIndex]], direction: .forward, animated: false)
      // the line above set the current image index as the chosen controller index,
      // and the line below set the current image index as the chosen bar indicator index
      cardViewModel.configureBarIndicators(barIndicators, addIndicator: addBarIndicator)
      // if there is an old view model, that means it's being reused
      // if none, means it's the initial set up for home or user detail
      // so check to set up for home
      if oldValue == nil && cardViewModel.isHome {
        disableScroll()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
      }
    }
  }
  
  init() {
    super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    addBarIndicator()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dataSource = self
    delegate = self
    view.backgroundColor = .clear
    setupBarIndicators()
  }
  
  func prepareForReuse() {
    cardViewModel.disableCurrentBarIndicator(barIndicators)
    for i in 0..<cardViewModel.urlsCount {
      barIndicators.arrangedSubviews[i].isHidden = true
    }
  }
  
  private func setupBarIndicators() {
    barIndicators.distribution = .fillEqually
    barIndicators.spacing = 4
    barIndicators.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(barIndicators)
    NSLayoutConstraint.activate([
      barIndicators.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
      barIndicators.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      barIndicators.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      barIndicators.heightAnchor.constraint(equalToConstant: 4)
    ])
  }
  
  private func addBarIndicator() {
    let barIndicator = UIView()
    barIndicator.layer.cornerRadius = 2
    barIndicator.layer.masksToBounds = true
    barIndicator.backgroundColor = .barDefaultColor
    self.barIndicators.addArrangedSubview(barIndicator)
  }
  
  private func disableScroll() {
    // if in the home, disable the scroll view so that user only can tap to scroll
    view.subviews.forEach {
      if let scrollView = $0 as? UIScrollView {
        scrollView.isScrollEnabled = false
      }
    }
  }

  // scroll to next image in home
  @objc private func handleTap(_ tap: UITapGestureRecognizer) {
    // barIndicators is shown means there are more than one image,
    // only in that scenario tap to the next card make sense
    guard !barIndicators.isHidden,
          !_transitionInProgress,
          let viewModel = cardViewModel else { return }
    _transitionInProgress = true
    viewModel.disableCurrentBarIndicator(barIndicators)
    let location = tap.location(in: view)
    let toRight = location.x > view.bounds.width / 2
    viewModel.nextCard(toRight: toRight)
    setViewControllers(
      [controllers[viewModel.currentImageIndex]],
      direction: toRight ? .forward : .reverse,
      animated: true
    ) { [weak self] _ in
      self?._transitionInProgress = false
    }
    viewModel.enableCurrentBarIndicator(barIndicators)
  }
  
}


extension SwipingPhotosController: UIPageViewControllerDataSource {
  // scroll to next image in detail
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController:
    UIViewController) -> UIViewController? {
    nextController(for: viewController, toRight: false)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController:
    UIViewController) -> UIViewController? {
    nextController(for: viewController, toRight: true)
  }
  
  private func nextController(for controller: UIViewController, toRight: Bool) -> PhotoController? {
    guard let page = (controller as? PhotoController)?.page else { return nil }
    let nextPage = cardViewModel.oneWayIndex(for: page, add: toRight ? 1 : -1)
    return nextPage == page ? nil : controllers[nextPage]
  }
}


extension SwipingPhotosController: UIPageViewControllerDelegate {
  // after completed transitioning to next controller, set up the bar indicators
  // setViewControllers with animated set to true doesn't trigger this method
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      guard let page = (viewControllers?.first as? PhotoController)?.page else { return }
      cardViewModel.disableCurrentBarIndicator(barIndicators)
      cardViewModel.currentImageIndex = page
      cardViewModel.enableCurrentBarIndicator(barIndicators)
    }
  }
}
