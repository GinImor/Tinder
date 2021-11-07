//
// MatchUsersController.swift
// Tinder
//
// Created by Gin Imor on 4/23/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class MatchUsersController: GIGridController<MatchUser>, UICollectionViewDelegateFlowLayout {
  
  override var ItemCellClass: GIGridCell<MatchUser>.Type? { MatchUserCell.self }
  
  var hasMoreMatches = true
  
  var didTappedItem: ((MatchUser) -> Void)?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fetchData()
  }
  
  override func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {
    flowLayout.scrollDirection = .horizontal
    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 16)
  }
  
  private func fetchData() {
    db.fetchMatches {
      [weak self] matches, error in
      guard let strongSelf = self else { return }
      if let error = error {
        print("fetching matches error", error)
        return
      }
      print("successfully fetch matches: ", matches!)
      strongSelf.setGrid(matches!)
    }
  }
  
  override func additionalSetupForCell(_ cell: GIGridCell<MatchUser>, indexPath: IndexPath) {
    let cell = cell as! MatchUserCell
    let uid = grid[indexPath.item].uid
    let (name, imageUrl) = db.matchUserInfo(for: uid)
    if imageUrl == nil {
      // hit the placeholder, means the data is being fetched, so register to the db
      // so that when the data arrived the cell will be notified
      db.registerMatchUserCell(cell)
    } else {
      cell.setUsername(name, imageUrl: imageUrl)
    }
    // once reach the last item, fetch more to the grid
    if indexPath.item == grid.count - 1 && hasMoreMatches {
      db.fetchMatches {
        [weak self] (matchUsers, error) in
        if let error = error {
          print("fetch matches error: ", error)
        }
        guard let matchUsers = matchUsers else { return }
        if matchUsers.isEmpty {
          self?.hasMoreMatches = false
          return
        }
        self?.grid.append(contentsOf: matchUsers)
        self?.collectionView.reloadData()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 80, height: collectionView.bounds.height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didTappedItem?(grid[indexPath.item])
  }
  
}
