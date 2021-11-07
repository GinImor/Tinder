//
// RecentMessagesNavBar.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

protocol RecentMessagesNavBarDelegate: AnyObject {
  func didTappedBackButton()
}

class RecentMessagesNavBar: UIView {
  
  weak var delegate: RecentMessagesNavBarDelegate?

  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .white
    shadow(opacity: 0.2, radius: 8, offset: CGSize(height: 10), color: .whiteWithAlpha(0.3))

    let iconImageView = UIImageView.system(
      imageName: "bubble.left.and.bubble.right.fill", textStyle: .largeTitle, tintColor: .primaryColor)
    let messageLabel = UILabel.new("Messages", .title2, .primaryColor, .center)
    let feedLabel = UILabel.new("Feed", .title2, .label, .center)
    let backButton = UIButton.system(imageName: "flame.fill", textStyle: .headline, tintColor: .lightGray)
    
    vStack(
      // increase content hugging priority to strech the labels' height
      iconImageView.withCH(999, axis: .vertical),
      hStack(messageLabel, feedLabel).distributing(.fillEqually)
    )
    .padding(edgeInsets: .init(16))
    .add(to: self).filling(self)
  
    backButton.add(to: self).hLining(.leading, value: 16).vLining(.centerY, to: iconImageView)
      .addTarget(self, action: #selector(handleBack))
  }
  
  @objc private func handleBack() {
    delegate?.didTappedBackButton()
  }
  
}
