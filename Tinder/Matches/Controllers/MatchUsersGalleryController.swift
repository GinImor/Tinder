//
//  MatchUsersGalleryController.swift
//  Tinder
//
//  Created by Gin Imor on 12/4/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import CoreData

class MatchUsersGalleryController: FetchedResultsCollectionViewController {
  
  private let matchUserCellId = "MatchUserCellId"
  private var matchUsers = [MatchUser]()
  private var hasMoreMatches = true
  
  var didTappedMatchUser: ((MatchUser) -> Void)?
  
  lazy private var fetchedResultsController: NSFetchedResultsController<MatchUser> = {
    let fetchRequest = MatchUser.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(MatchUser.matchDate), ascending: false)]
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: tempDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self
    return frc
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchData()
  }
  
  private func setupViews() {
    collectionView.backgroundColor = .white
    collectionView.register(MatchUserCell.self, forCellWithReuseIdentifier: matchUserCellId)
  }
  
  private func fetchData() {
    try? fetchedResultsController.performFetch()
  }
  
  func fetchMatchUsers() {
    db.listenToMatches { error in
      if let error = error {
        print("fetching matches error", error)
        return
      }
      print("successfully fetch matches")
    }
  }

}


// MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension MatchUsersGalleryController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 80, height: collectionView.bounds.height)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didTappedMatchUser?(fetchedResultsController.object(at: indexPath))
  }
  
}


// MARK: - UICollectionViewDataSource

extension MatchUsersGalleryController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: matchUserCellId, for: indexPath) as! MatchUserCell
    if let uid = fetchedResultsController.object(at: indexPath).id {
      cell.uid = uid
      let (name, imageUrl) = db.matchUserInfo(for: uid)
      if imageUrl == nil {
        // hit the placeholder, means the data is being fetched, so register to the db
        // so that when the data arrived the cell will be notified
        db.registerMatchUserCell(cell)
      } else {
        cell.setUsername(name, imageUrl: imageUrl)
      }
    }
    return cell
  }
  
}
