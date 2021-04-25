//
// MatchesNavBar.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MatchesNavBar: UIView {
  
  let backButton = UIButton.system(imageName: "flame.fill", textStyle: .headline, tintColor: .lightGray)
  
  override init(frame: CGRect = .zero) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let iconImageView = UIImageView.system(
      imageName: "bubble.left.and.bubble.right.fill", textStyle: .largeTitle, tintColor: .primaryColor)
    let messageLabel = navBarLabel(text: "Messages", textColor: .primaryColor)
    let feedLabel = navBarLabel(text: "Feed")
  
    let navBar = View(self, subView: VStack(
      iconImageView.withHugging(999),
      HStack(messageLabel, feedLabel)
        .distribution(.fillEqually).view
    )
      .spacing()
      .view.padding(edgeInsets: .init(top: 16, leftRight: 16, bottom: 16))
    )
      .backgroundColor(.white)
      .shadow(
        .opacity(0.2),
        .radius(8),
        .offset(CGSize(width: 0, height: 10)),
        .color(UIColor.whiteWithAlpha(0.3))
      ).view
    
    backButton.add(to: navBar).hLining(.leading, value: 16).vLining(.centerY, to: iconImageView)
  }
  
  private func navBarLabel(text: String, textColor: UIColor? = nil) -> UILabel {
    let label = UILabel()
    label.text = text
    label.font = UIFont.preferredFont(forTextStyle: .title2)
    if let textColor = textColor {
      label.textColor = textColor
    }
    label.textAlignment = .center
    return label
  }
}
