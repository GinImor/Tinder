//
// MatchUserCell.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class MatchUserCell: UserInfoCell<MatchUser> {
  
  override func setup() {
    super.setup()
    profileImageView = UIImageView.new(cornerRadius: 30)
    usernameLabel = UILabel.new("", .caption1, UIColor(rgb: 57), .center)
    vStack(
      profileImageView.sizing(to: 60),
      usernameLabel
    ).aligning(.center).add(to: self).filling()
  }

  override func didSetItem() {
    uid = item.uid
  }
  
  override func prepareForReuse() {
    db.unregisterMatchUserCell(self)
    super.prepareForReuse()
  }
  
}
