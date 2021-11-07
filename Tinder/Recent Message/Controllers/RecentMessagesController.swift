//
// RecentMessagesController.swift
// Tinder
//
// Created by Gin Imor on 4/17/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import FirebaseFirestore
import GILibrary

class RecentMessagesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

  var user: User?
  
  private let matchesNavBar = RecentMessagesNavBar()

  private var messageUserId = [String]()
  private let cache = RecentMessagesLRUCache(capacity: 10)

  private let itemId = "RecentMessageCell"
  private let headerId = "MatchUsersHeader"
  
  
  init() {
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupLayout()
    fetchData()
  }
  
  // possible transition
  // in home
  // 1 transition to recent messages, will appear -> did appear
  // in recent messages
  // 2 swipe back to home, if fail, will disappear -> will appear -> did appear
  // 3 trantition to chat log, back to Home, will disappear -> did disappear
  // in chat log
  // 4 swipe back to recent messages, if fail, will appear -> will disappear -> did disappear
  // 5 back to recent messages, will appear -> did appear
  // that means, only in case 3 the app reset db for recent messages
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    // if it's transitioning to ChatLogCcontroller, don't need to do this
    // only applied to removing from the navigation controller
    if isMovingFromParent {
      // set the lastMatchesTimestamp to nil for MatchUsersController
      db.nullifyLastMatchesTimestamp()
      db.removeRecentMessagesListener()
    }
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    // collection view content begin after matchesNavBar
    // The safe area insets are added to the values in the contentInset to obtain
    // the final value of adjustedContentInset
    // so when setting contentInset, don't need to consider safeArea
    // just add the extra width and height
    if collectionView.contentInset.top != matchesNavBar.frame.height {
      let navBarHeight = matchesNavBar.frame.height
      collectionView.contentInset.top = navBarHeight
      collectionView.verticalScrollIndicatorInsets.top = navBarHeight
    }
  }
  
  private func setupViews() {
    collectionView.backgroundColor = .white
    collectionView.register(RecentMessageCell.self, forCellWithReuseIdentifier: itemId)
    collectionView.register(MatchUsersHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerId)
    navigationController?.navigationBar.isHidden = true
    matchesNavBar.delegate = self
  }
  
  private func setupLayout() {
    UIView(backgroundColor: .white).add(to: view)
      .vLining(.top, to: view).hLining(to: view)
      .vLining(.bottom, .top)
    matchesNavBar.add(to: view).vLining(.top).hLining()
    
    let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    // distinguish contentInset and sectionInset
    flowLayout.sectionInset.top = 16
    flowLayout.headerReferenceSize = CGSize(width: 0, height: 180)
    flowLayout.minimumLineSpacing = 0
  }
  
 
  private func fetchData() {
    db.fetchCurrentUserIfNecessary {
      [weak self] user, error in
      if let error = error {
        print("fetch current user error", error)
        // if can't get a user, dismiss back to home
        self?.handleDismiss()
        return
      }
      self?.user = user
      self?.fetchRecentMessages()
    }
  }

  private func fetchRecentMessages() {
    db.listenToRecentMessages { [weak self] recentMessages, error in
      // listener observes the recent message updates in firestore
      guard let self = self else { return }
      if let error = error {
        print("fetch recent messages error", error)
        return
      }
      print("successfully fetch recent messages")
      guard let recentMessages = recentMessages else { return }
      print("recent messages ", recentMessages)
      recentMessages.forEach({ self.cache.put(value: $0) })
      self.messageUserId = self.cache.allKeys()
      self.collectionView.reloadData()
    }
  }
 
  @objc private func handleDismiss() {
    navigationController?.popViewController(animated: true)
  }
  
  override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    if kind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(
        ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! MatchUsersHeader
      configureHeader(header)
      return header
    }
    return UICollectionReusableView()
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    messageUserId.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: itemId, for: indexPath)
     as! RecentMessageCell
    let recentMessage = recentMessageFor(indexPath)!
    let uid = recentMessage.uid
    cell.item = recentMessage
    let (name, imageUrl) = db.matchUserInfo(for: uid)
    if imageUrl == nil {
      // the user info is just a placeholder, doesn't have the real content
      // so register the cell to receive the user info when it arrived
      db.registerRecentMessageCell(cell)
    } else {
      // does have the actual content, directly set it.
      cell.setUsername(name, imageUrl: imageUrl)
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.bounds.width, height: 100)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let recentMessage = recentMessageFor(indexPath) else { return }
    let chatLogController = ChatLogController(match: recentMessage, current: user)
    navigationController?.pushViewController(chatLogController, animated: true)
  }
  
  private func recentMessageFor(_ indexPath: IndexPath) -> RecentMessage? {
    cache.get(key: messageUserId[indexPath.item])
  }
  
  private func configureHeader(_ header: MatchUsersHeader) {
    header.setTappedItemHandler { [unowned self] (matchUser) in
      let chatLogController = ChatLogController(match: matchUser, current: user)
      self.navigationController?.pushViewController(chatLogController, animated: true)
     }
   }
   
}


extension RecentMessagesController: RecentMessagesNavBarDelegate {
  func didTappedBackButton() { handleDismiss() }
}
