//
// MatchesController.swift
// Tinder
//
// Created by Gin Imor on 4/17/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD
import Firebase

class MatchesController: CollectionHeaderController<RecentMessageCell, RecentMessage, MatchesHeader>
  , UICollectionViewDelegateFlowLayout{
  
  let matchesNavBar = MatchesNavBar()
  
  private var recentMessages = [String: RecentMessage]()
  
  var user: User?
  
  private var listener: ListenerRegistration?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupLayout()
    fetchData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isMovingFromParent {
      listener?.remove()
    }
  }
  
  private func fetchData() {
    listener = TinderFirebaseService.fetchRecentMessages(
      nextMessageHandler: { [weak self] in
        self?.recentMessages[$0.uid] = $0
    }, completion: { [weak self] error in
      if let error = error {
        print("fetch recent messages error", error)
        return
      }
      print("successfully fetch recent messages")
      self?.resetItems()
    })
  }
  
  private func resetItems() {
    let messages = Array(recentMessages.values)
    items = messages.sorted { message1, message2 in
      message1.timestamp.compare(message2.timestamp) == .orderedDescending
    }
    collectionView.reloadData()
  }
  
  override func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {
    flowLayout.sectionInset.top = 16
    flowLayout.headerReferenceSize = CGSize(width: 0, height: 180)
    flowLayout.minimumLineSpacing = 0
  }
  
  override func setupViews() {
    super.setupViews()
    navigationController?.navigationBar.isHidden = true
    matchesNavBar.backButton.addTarget(self, action: #selector(handleDismiss))
  }
  
  private func setupLayout() {
    UIView.new(backgroundColor: .white).add(to: view)
      .filling(view) { $0[2].isActive = false }
      .vLining(.bottom, .top)
    matchesNavBar.add(to: view).vLining(.top).hLining(.horizontal)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if collectionView.contentInset.top != matchesNavBar.frame.height {
      let navBarHeight = matchesNavBar.frame.height
      collectionView.contentInset.top = navBarHeight
      collectionView.verticalScrollIndicatorInsets.top = navBarHeight
    }
  }
  
  override func configureHeader(_ header: MatchesHeader) {
    header.didTapItem = { [unowned self] (matchUser) in
      let chatLogController = ChatLogController(match: matchUser, current: user)
      self.navigationController?.pushViewController(chatLogController, animated: true)
    }
  }
  
  @objc func handleDismiss() {
    navigationController?.popViewController(animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.bounds.width, height: 100)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let recentMessage = items[indexPath.item]
    let dataDic = [
      "name": recentMessage.username,
      "uid": recentMessage.uid,
      "profileImageUrl": recentMessage.profileImageUrl
    ]
    let matchUser = MatchUser(userDic: dataDic)
    let chatLogController = ChatLogController(match: matchUser, current: user)
    navigationController?.pushViewController(chatLogController, animated: true)
  }
}
