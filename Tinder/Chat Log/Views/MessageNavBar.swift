//
// MessageNavBar.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class MessageNavBar: UIView {
  
  private let match: Match
  
  private let profileImageView = UIImageView.new()
  private let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "USERNAME"
    label.textColor = .darkGray
    label.textAlignment = .center
    return label
  }()
  let backButton = UIButton.system(
    imageName: "chevron.left", textStyle: .title3, tintColor: UIColor(rgb: (255, 81, 80)))
  let flagButton = UIButton.system(
    imageName: "flag", textStyle: .title3, tintColor: UIColor(rgb: (255, 81, 80)))
  
  
  init(match: Match) {
    self.match = match
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .white
    hStack(
      backButton,
      vStack(profileImageView, nameLabel).aligning(.center),
      flagButton
    )
    .aligning(.center).padding(edgeInsets: .init(16))
    .add(to: self).filling(self)
   
    profileImageView.sizing(to: 44).roundedCorner(22)
    profileImageView.addBorder(width: 0.5, uiColor: UIColor(white: 0.5, alpha: 0.5))
    shadow(opacity: 0.2, radius: 8, offset: CGSize(height: 10), color: .whiteWithAlpha(0.3))
    
    let (name, imageUrl) = db.matchUserInfo(for: match.uid)
    if imageUrl == nil {
      db.selectedMatchUid = match.uid
      NotificationCenter.default.addObserver(self, selector: #selector(handleUserInfo), name: Notification.Name(match.uid), object: nil)
    } else {
      setUserInfo(name: name, imageUrl: imageUrl)
    }
  }
  
  @objc private func handleUserInfo(notification: Notification) {
    guard let userInfo = notification.object as? [String: String?],
          // get value from dictionary add extra optional type to value type,
          // in this case, is String??
          let name = userInfo["name"],
          let imageUrl = userInfo["imageUrl"] else { return }
    setUserInfo(name: name, imageUrl: imageUrl)
    NotificationCenter.default.removeObserver(self)
  }
  
  func setUserInfo(name: String?, imageUrl: String?) {
    nameLabel.text = name
    nameLabel.textColor = .label
    if let imageUrl = imageUrl {
      profileImageView.sd_setImage(with: URL(string: imageUrl))
    }
  }
  
}

