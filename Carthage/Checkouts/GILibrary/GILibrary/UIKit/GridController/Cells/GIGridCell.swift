//
//  GIGridCell.swift
//  GILibrary
//
//  Created by Gin Imor on 4/19/21.
//
//

import UIKit

open class GIGridCell<Item>: UICollectionViewCell {
  
  // MARK: - Methods to Override
  open func didSetItem() {}
  open func setup() {
    backgroundColor = .white
  }
  
  open var item: Item! {
    didSet { didSetItem() }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
