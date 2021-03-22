//
//  HomeView.swift
//  Tinder
//
//  Created by Gin Imor on 3/21/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class HomeView: UIView {

  @IBOutlet weak var topStackView: UIStackView! {
    didSet {
      topStackView.isLayoutMarginsRelativeArrangement = true
      topStackView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
  }

  @IBOutlet weak var cardDeckView: UIView!

  
  private var didAddCornerRadius = false
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if !didAddCornerRadius, let cardViews = cardDeckView.subviews as? [CardView] {
      didAddCornerRadius = true
      cardViews.forEach { (cardView) in
        cardView.addCornerEffect()
      }
    }
  }
}
