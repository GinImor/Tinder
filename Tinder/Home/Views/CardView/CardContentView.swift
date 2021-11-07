//
//  CardContentView.swift
//  Tinder
//
//  Created by Gin Imor on 11/8/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CardContentView: UIView {
  
  private let gradientLayer = CAGradientLayer()
    
  @IBOutlet weak var informationLabel: UILabel!
  @IBOutlet private weak var informationContainerView: UIView! {
    didSet {
      gradientLayer.colors = [UIColor.clear, .black].map { $0.cgColor }
      gradientLayer.locations = [0.0, 1.3]
        layer.insertSublayer(gradientLayer, below: informationContainerView.layer)
    }
  }

  @IBAction func showDetail(_ sender: Any) {
    didTappedDetailArea?()
  }
  
  var didTappedDetailArea: (() -> Void)?
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = CGRect(
      x: informationContainerView.frame.minX - 8,
      y: informationContainerView.frame.minY,
      width: informationContainerView.frame.width + 16,
      height: informationContainerView.frame.height + 8
    )
  }
}
