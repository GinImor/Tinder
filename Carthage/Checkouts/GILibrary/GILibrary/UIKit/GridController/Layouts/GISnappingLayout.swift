//
//  GISnappingLayout.swift
//  GILibrary
//
//  Created by Gin Imor on 4/29/21.
//
//

import UIKit

open class GISnappingLayout: UICollectionViewFlowLayout {
  
  open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                    withScrollingVelocity velocity: CGPoint) -> CGPoint {
    guard let collectionView = collectionView else {
      return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
        withScrollingVelocity: velocity)
    }
    
    var offsetAdjustment = CGFloat.greatestFiniteMagnitude
    let horizontalOffset = proposedContentOffset.x + sectionInset.left
    
    let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.bounds.size.width,
      height: collectionView.bounds.size.height)
    
    let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
    
    // find the closest item to proposed offset x + inset left
    layoutAttributesArray?.forEach({ (layoutAttributes) in
      let itemOffset = layoutAttributes.frame.origin.x
      if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
        offsetAdjustment = itemOffset - horizontalOffset
      }
    })
    
    return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
  }
}
