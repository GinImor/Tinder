//
// MessageNavBar.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MessageNavBar: UIView {
  
  let profileImageView = UIImageView.new(imageName: "ross")
  let nameLabel = UILabel.new("USERNAME", textAlignment: .center)
  let backButton = UIButton.system(imageName: "chevron.left", textStyle: .title3, tintColor: UIColor(rgb: (255, 81,
    80)))
  let flagButton = UIButton.system(imageName: "flag", textStyle: .title3, tintColor: UIColor(rgb: (255, 81, 80)))
  
  private let match: MatchUser
  
  init(match: MatchUser) {
    self.match = match
    super.init(frame: .zero)
    setup()
  }
  
  private func setup() {
    View(self, subView: HStack(
      backButton,
      VStack(profileImageView, nameLabel)
        .aliment(.center).spacing().view,
      flagButton
    ).aliment(.center)
      .view.padding(edgeInsets: .init(16))).backgroundColor(.white).shadow(
      .opacity(0.2),
      .radius(8),
      .offset(CGSize(width: 0, height: 10)),
      .color(UIColor.whiteWithAlpha(0.3))
    )
    profileImageView.sizing(to: 44).roundedCorner(22)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

