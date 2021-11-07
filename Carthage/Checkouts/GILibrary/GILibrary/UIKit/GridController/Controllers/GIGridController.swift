//
//  GIGridController.swift
//  GILibrary
//
//  Created by Gin Imor on 4/19/21.
//
//

import UIKit

open class GIBaseGridController: UICollectionViewController {
  
  public convenience init(scrollDirection: UICollectionView.ScrollDirection = .vertical) {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = scrollDirection
    self.init(flowLayout: flowLayout)
  }
  
  public init(flowLayout: UICollectionViewFlowLayout) {
    super.init(collectionViewLayout: flowLayout)
  }
  
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

open class GIGridController<Item>: GIBaseGridController {
  
  // MARK: - Properties to Override
  open var ItemCellClass: GIGridCell<Item>.Type? { nil}
  open var HeaderClass: UICollectionReusableView.Type? { nil }
  open var FooterClass: UICollectionReusableView.Type? { nil }
  
  // MARK: - Methods to Override
  open func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {}
  open func configureHeader(_ header: UICollectionReusableView) {}
  open func configureFooter(_ footer: UICollectionReusableView) {}
  open func additionalSetupForCell(_ cell: GIGridCell<Item>, indexPath: IndexPath) {}
  
  open var grid: [Item] = []
  
  let ItemCellId = "ItemCellId"
  let supplementaryCellId = "supplementaryCellId"
  
  public var flowLayout: UICollectionViewFlowLayout {
    collectionView.collectionViewLayout as! UICollectionViewFlowLayout
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }
  
  open func setupViews() {
    collectionView.backgroundColor = .white
    collectionView.register(ItemCellClass.self, forCellWithReuseIdentifier: ItemCellId)
    collectionView.register(HeaderClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: supplementaryCellId)
    collectionView.register(FooterClass.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
      withReuseIdentifier: supplementaryCellId)
    setupFlowLayout(flowLayout)
  }
  
  public func setGrid(_ grid: [Item]) {
    self.grid = grid
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }
  
  open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    grid.count
  }
  
  open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCellId, for: indexPath)
      as! GIGridCell<Item>
    cell.item = grid[indexPath.item]
    additionalSetupForCell(cell, indexPath: indexPath)
    return cell
  }
  
  open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at
  indexPath: IndexPath) -> UICollectionReusableView {
    let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: supplementaryCellId
      , for: indexPath)
    if kind == UICollectionView.elementKindSectionHeader {
      configureHeader(cell)
    } else if kind == UICollectionView.elementKindSectionFooter {
      configureFooter(cell)
    }
    return cell
  }
  
}
