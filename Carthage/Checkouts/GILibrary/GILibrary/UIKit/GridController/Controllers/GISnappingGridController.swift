//
//  GISnappingGridController.swift
//  GILibrary
//
//  Created by Gin Imor on 4/29/21.
//
//

import UIKit

open class GISnappingGridController<Item>: GIGridController<Item> {
  
  public init(scrollDirection: UICollectionView.ScrollDirection = .horizontal) {
    let layout = GISnappingLayout()
    layout.scrollDirection = scrollDirection
    super.init(flowLayout: layout)
    collectionView.decelerationRate = .fast
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
