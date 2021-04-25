//
// CollectionCell.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CollectionCell<Item>: UICollectionViewCell {

  var item: Item! {
    didSet { didSetItem() }
  }
  
  
  // MARK: - Methods to Override
  func setup() {
    backgroundColor = .white
  }
  
  func didSetItem() {}
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
}
