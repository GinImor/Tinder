//
//  GIGridSelfSizingCell.swift
//  GILibrary
//
//  Created by Gin Imor on 4/22/21.
//
//

import UIKit

open class GIGridSelfSizingCell<Item>: GIGridCell<Item> {
  
  private var widthConstraint: NSLayoutConstraint!
  public var width: CGFloat? {
    didSet {
      guard let width = width else { return }
      widthConstraint.constant = width
      widthConstraint.isActive = true
    }
  }
  
  open override func setup() {
    super.setup()
    contentView.disableTAMIC().filling(self).sizing(width: 50) {
      $0[0].isActive = false
      self.widthConstraint = $0[0]
    }
  }
}
