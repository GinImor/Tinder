//
// MatchUserCell.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class MatchUserCell: UICollectionViewCell, UserInfoCell {
  
  var profileImageView: UIImageView!
  var usernameLabel: UILabel!
  var uid: String!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    profileImageView = UIImageView.new(cornerRadius: 30)
    usernameLabel = UILabel.new("", .caption1, UIColor(rgb: 57), .center)
    vStack(
      profileImageView.sizing(to: 60),
      usernameLabel
    ).aligning(.center).add(to: self).filling()
  }
  
  func setUsername(_ name: String?, imageUrl: String?) {
    _setUsername(name, imageUrl: imageUrl)
  }
  
  override func prepareForReuse() {
    db.unregisterMatchUserCell(self)
    _prepareForReuse()
    super.prepareForReuse()
  }
  
}
