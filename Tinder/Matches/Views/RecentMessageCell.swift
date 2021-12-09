//
// RecentMessageCell.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

protocol UserInfoCell: AnyObject {
  var profileImageView: UIImageView! { get }
  var usernameLabel: UILabel! { get }
  var uid: String! { get set }
  
  func setUsername(_ name: String?, imageUrl: String?)
}

extension UserInfoCell {
  
  func _setUsername(_ name: String?, imageUrl: String?) {
    usernameLabel.text = name
    if let imageUrlString = imageUrl {
      profileImageView.sd_setImage(with: URL(string: imageUrlString))
    }
  }
  
  func _prepareForReuse() {
    profileImageView.image = nil
    usernameLabel.text = nil
    uid = nil
  }
  
}


class RecentMessageCell: UITableViewCell, UserInfoCell {
  
  var profileImageView: UIImageView!
  var usernameLabel: UILabel!
  var uid: String!
  
  var message: String?
  
  let messageLabel = UILabel.new("", .footnote, 2)
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    profileImageView = UIImageView.new(cornerRadius: 45)
    profileImageView.addBorder(width: 0.5, uiColor: UIColor(white: 0.5, alpha: 0.5))
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
  
  func setUsername(_ name: String?, imageUrl: String?) {
    _setUsername(name, imageUrl: imageUrl)
    messageLabel.text = message
  }
  
  override func prepareForReuse() {
    db.unregisterRecentMessageCell(self)
    _prepareForReuse()
    super.prepareForReuse()
  }
  
}
