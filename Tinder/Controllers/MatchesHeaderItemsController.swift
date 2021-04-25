//
// MatchesHeaderItemsController.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class MatchesHeaderItemsController: CollectionController<MatchesCell, MatchUser>, UICollectionViewDelegateFlowLayout {
  
  var didTapItem: ((MatchUser) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchData()
  }
  
  override func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {
    flowLayout.scrollDirection = .horizontal
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 16)
  }
  
  private func fetchData() {
    TinderFirebaseService.fetchMatches { [weak self] matches, error in
      guard let strongSelf = self else { return }
      if let error = error {
        print("fetching matches error", error)
        return
      }
      print("successfully fetch matches")
      strongSelf.items = matches!
      strongSelf.collectionView.reloadData()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 80, height: collectionView.bounds.height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didTapItem?(items[indexPath.item])
  }
}
