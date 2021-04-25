//
// RecentMessageCell.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class RecentMessageCell: CollectionCell<RecentMessage> {
  
  let profileImageView = UIImageView.new()
  let usernameLabel = UILabel.new(textStyle: .subheadline)
  let messageLabel = UILabel.new(textStyle: .footnote)
  
  override func setup() {
    super.setup()
    HStack(
      profileImageView.sizing(to: 90).roundedCorner(45),
      VStack(usernameLabel, messageLabel).spacing().view
    )
      .aliment(.center).spacing(16)
      .view.add(to: self).filling()
      .padding(edgeInsets: .init(vertical: 0, horizontal: 16))
    messageLabel.numberOfLines = 2
    addBottomBorder(leadingAnchor: usernameLabel.leadingAnchor)
  }
  
  override func didSetItem() {
    profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
    usernameLabel.text = item.username
    messageLabel.text = item.text
  }
  
}
