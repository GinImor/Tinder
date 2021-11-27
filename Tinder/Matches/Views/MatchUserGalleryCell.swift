//
//  MatchUserGalleryCell.swift
//  Tinder
//
//  Created by Gin Imor on 11/26/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MatchUserGalleryCell: UITableViewCell {
  
  weak var collectionView: UICollectionView!
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = .init(0, 16)
    flowLayout.scrollDirection = .horizontal
    let cv = UICollectionView(frame: .zero, collectionViewLayout:flowLayout)
    cv.backgroundColor = .white
    collectionView = cv
    cv.add(to: contentView).filling(contentView, edgeInsets: .init(8, 0))
  }
}
