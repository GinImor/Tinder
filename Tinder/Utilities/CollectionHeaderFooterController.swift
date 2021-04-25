//
// CollectionHeaderFooterController.swift
// Tinder
//
// Created by Gin Imor on 4/19/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CollectionController<Cell: CollectionCell<Item>, Item>:
  CollectionHeaderController<Cell, Item, UICollectionReusableView> {}


class CollectionHeaderController<Cell: CollectionCell<Item>, Item, Header: UICollectionReusableView>:
  CollectionHeaderFooterController<Cell, Item, Header, UICollectionReusableView> {}


class CollectionHeaderFooterController<Cell: CollectionCell<Item>, Item, Header: UICollectionReusableView, Footer:
UICollectionReusableView>: UICollectionViewController {
  
  init(scrollDirection: UICollectionView.ScrollDirection = .vertical) {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = scrollDirection
    super.init(collectionViewLayout: flowLayout)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  let ItemCellId = "ItemCellId"
  let supplementaryCellId = "supplementaryCellId"
  
  var items: [Item] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  func setupViews() {
    collectionView.backgroundColor = .white
    collectionView.register(Cell.self, forCellWithReuseIdentifier: ItemCellId)
    collectionView.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: supplementaryCellId)
    collectionView.register(Footer.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: supplementaryCellId)
    setupFlowLayout(collectionView.collectionViewLayout as! UICollectionViewFlowLayout)
  }
  
  
  // MARK: - Methods to Override
  func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {}
  
  func configureHeader(_ header: Header) {}
  func configureFooter(_ footer: Footer) {}
  
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    items.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCellId, for: indexPath) as! Cell
    cell.item = items[indexPath.item]
    return cell
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at
  indexPath: IndexPath) -> UICollectionReusableView {
    let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryCellId
      , for: indexPath)
    if kind == UICollectionView.elementKindSectionHeader {
      configureHeader(cell as! Header)
    } else if kind == UICollectionView.elementKindSectionFooter {
      configureFooter(cell as! Footer)
    }
    return cell
  }
  
}
