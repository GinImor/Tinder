//
// MatchesHeader.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MatchesHeader: UICollectionReusableView {
  
  let matchesHeaderItemsController = MatchesHeaderItemsController()
  
  var didTapItem: ((MatchUser) -> Void)? {
    didSet {
      matchesHeaderItemsController.didTapItem = didTapItem
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let labelColor = UIColor(rgb: (255, 98, 103))
    let newMatchesLabel = UILabel.new("New Matches", textStyle: .subheadline, textColor: labelColor)
    let messagesLabel = UILabel.new("Messages", textStyle: .subheadline, textColor: labelColor)
    VStack(
      HStack(newMatchesLabel).view.padding(.left, value: 16),
      matchesHeaderItemsController.view,
      HStack(messagesLabel).view.padding(.left, value: 16)
    )
      .spacing(20)
      .view.add(to: self).filling()
      .padding(edgeInsets: .init(vertical: 8, horizontal: 0))
  }
}