//
// RecentMessageCell.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class UserInfoCell<T>: GIGridCell<T> {
  var profileImageView: UIImageView!
  var usernameLabel: UILabel!
  var uid: String!
  
  func setUsername(_ name: String?, imageUrl: String?) {
    usernameLabel.text = name
    if let imageUrlString = imageUrl {
      profileImageView.sd_setImage(with: URL(string: imageUrlString))
    }
  }
  
  override func prepareForReuse() {
    profileImageView.image = nil
    usernameLabel.text = nil
    uid = nil
  }
}


class RecentMessageCell: UserInfoCell<RecentMessage> {
  
  let messageLabel = UILabel.new("", .footnote, 2)

  override func setup() {
    super.setup()
    profileImageView = UIImageView.new(cornerRadius: 45)
    usernameLabel = UILabel.new("", .title3)
    messageLabel.textColor = .systemGray
    hStack(
      profileImageView.sizing(to: 90),
      vStack(usernameLabel, messageLabel)
    )
      .aligning(.center).spacing(16)
      .padding(edgeInsets: .init(0, 16))
      .add(to: self).filling()
    addBottomBorder(leadingAnchor: usernameLabel.leadingAnchor)
  }
  
  override func didSetItem() {
    uid = item.uid
  }
  
  override func setUsername(_ name: String?, imageUrl: String?) {
    super.setUsername(name, imageUrl: imageUrl)
    messageLabel.text = item.text
  }
  
  override func prepareForReuse() {
    db.unregisterRecentMessageCell(self)
    super.prepareForReuse()
  }
  
}
