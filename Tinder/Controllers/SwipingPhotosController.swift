//
// SwipingPhotosController.swift
// Tinder
//
// Created by Gin Imor on 4/14/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  var controllers: [PhotoController] = []
  
  public var cardViewModel: CardViewModel! {
    didSet {
      controllers = cardViewModel.imageUrls.map { PhotoController(imageUrl: $0) }
      setViewControllers([controllers[cardViewModel.currentImageIndex]], direction: .forward, animated: false)
      cardViewModel.configureBarIndicators(barIndicators)
      if cardViewModel.isHome {
        disableScroll()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
      }
    }
  }
  
  @objc func handleTap(_ tap: UITapGestureRecognizer) {
    guard !barIndicators.isHidden, let viewModel = cardViewModel else { return }
    viewModel.disableCurrentBarIndicator(barIndicators)
    let location = tap.location(in: view)
    if location.x > view.bounds.width / 2 {
      viewModel.nextCard(toRight: true)
      setViewControllers([controllers[viewModel.currentImageIndex]], direction: .forward, animated: true)
    } else {
      viewModel.nextCard(toRight: false)
      setViewControllers([controllers[viewModel.currentImageIndex]], direction: .reverse, animated: true)
    }
    viewModel.enableCurrentBarIndicator(barIndicators)
  }
  
  private let barIndicators = UIStackView()
  
  private let barDefaultColor = UIColor(white: 0.0, alpha: 0.1)
  
  private func disableScroll() {
    view.subviews.forEach {
      if let scrollView = $0 as? UIScrollView {
        scrollView.isScrollEnabled = false
      }
    }
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                          previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    let currentController = viewControllers?.first
    if let index = controllers.firstIndex(where: { $0 === currentController }) {
      barIndicators.arrangedSubviews.forEach { $0.backgroundColor = barDefaultColor }
      barIndicators.arrangedSubviews[index].backgroundColor = .white
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    dataSource = self
    delegate = self
    setupBarIndicators()
  }
  
  private func setupBarIndicators() {
    barIndicators.distribution = .fillEqually
    barIndicators.spacing = 8
    barIndicators.disableTAMIC()
    view.addSubview(barIndicators)
    NSLayoutConstraint.activate([
      barIndicators.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      barIndicators.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      barIndicators.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      barIndicators.heightAnchor.constraint(equalToConstant: 5)
    ])
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController:
    UIViewController) -> UIViewController? {
    guard let index = controllers.firstIndex(where: { $0 === viewController }),
      index > 0 else { return nil }
    return controllers[index - 1]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController:
    UIViewController) -> UIViewController? {
    guard let index = controllers.firstIndex(where: { $0 === viewController }),
          index < controllers.count - 1 else { return nil }
    return controllers[index + 1]
  }
}