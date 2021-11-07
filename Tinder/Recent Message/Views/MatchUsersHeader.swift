//
// MatchUsersHeader.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class MatchUsersHeader: UICollectionReusableView {
  
  let matchUsersController = MatchUsersController()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let labelColor = UIColor(rgb: (255, 98, 103))
    let newMatchesLabel = UILabel.new("New Matches", .subheadline, labelColor, .left)
    let messagesLabel = UILabel.new("Messages", .subheadline, labelColor, .left)
    vStack(
      hStack(newMatchesLabel).padding(.left, value: 16),
      matchUsersController.view,
      hStack(messagesLabel).padding(.left, value: 16)
    )
      .spacing(20).add(to: self).filling()
      .padding(edgeInsets: .init(8, 0))
  }
  
  func setTappedItemHandler(_ handler: @escaping (MatchUser) -> Void) {
    matchUsersController.didTappedItem = handler
  }
  
}
