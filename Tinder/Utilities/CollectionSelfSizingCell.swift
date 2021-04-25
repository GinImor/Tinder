//
// CollectionSelfSizingCell.swift
// Tinder
//
// Created by Gin Imor on 4/22/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CollectionSelfSizingCell<Item>: CollectionCell<Item> {
  
  private var widthConstraint: NSLayoutConstraint!
  var width: CGFloat? {
    didSet {
      guard let width = width else { return }
      widthConstraint.constant = width
      widthConstraint.isActive = true
    }
  }
  
  override func setup() {
    super.setup()
    contentView.filling(self).sizing(width: 50) {
      $0[0].isActive = false
      self.widthConstraint = $0[0]
    }
  }
}
