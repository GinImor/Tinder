//
// MatchesCell.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MatchesCell: CollectionCell<MatchUser> {
  
  let profileImageView = UIImageView.new(imageName: "ross")
  let usernameLabel: UILabel = {
    let label = UILabel()
    label.text = "user name is in here"
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.textColor = UIColor(rgb: 57)
    label.textAlignment = .center
    return label
  }()
  
  override func setup() {
    super.setup()
    VStack(
      profileImageView.sizing(to: 60).roundedCorner(30),
      usernameLabel
    ).aliment(.center).view.add(to: self).filling()
  }
  
  override func didSetItem() {
    usernameLabel.text = item.name
    profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
  }
}
