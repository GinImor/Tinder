//
//  LogoutFooterButton.swift
//  Tinder
//
//  Created by Gin Imor on 11/2/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class LogoutFooterButton: UIButton {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    setTitle("Log out", for: .normal)
    setTitleColor(.systemRed, for: .normal)
    backgroundColor = .white
    titleLabel?.font = .systemFont(ofSize: 20)
    contentEdgeInsets = .init(16, 0)
    layer.masksToBounds = true
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = floor(bounds.height / 2)
  }
}
