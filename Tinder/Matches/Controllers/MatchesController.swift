//
//  MatchesController.swift
//  Tinder
//
//  Created by Gin Imor on 11/26/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class MatchesController: UIViewController {

  var user: User?
  
  private let matchesNavBar = MatchesNavBar()
  private var hasMoreMatches = true
  private var matchUsers = [MatchUser]()
  
  private var messageUserId = [String]()
  private let cache = RecentMessagesLRUCache(capacity: 10)

  private let matchUserCellId = "MatchUserCellId"
  private let RecentMessageCellId = "RecentMessageCellId"
  
  private var matchUserGalleryCell = MatchUserGalleryCell(style: .default, reuseIdentifier: "")
  
  private weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
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
    // table view content begin after matchesNavBar
    // The safe area insets are added to the values in the contentInset to obtain
    // the final value of adjustedContentInset
    // so when setting contentInset, don't need to consider safeArea
    // just add the extra width and height
    if tableView.contentInset.top != matchesNavBar.frame.height {
      let navBarHeight = matchesNavBar.frame.height
      tableView.contentInset.top = navBarHeight
      tableView.verticalScrollIndicatorInsets.top = navBarHeight
    }
  }
  
  private func setupViews() {
    let tv = UITableView()
    tv.delegate = self
    tv.dataSource = self
    tv.backgroundColor = .white
    tv.register(RecentMessageCell.self, forCellReuseIdentifier: RecentMessageCellId)
    tv.separatorStyle = .none
    tv.add(to: view).filling(view)
    tableView = tv
    
    let cv = matchUserGalleryCell.collectionView
    cv?.delegate = self
    cv?.dataSource = self
    cv?.register(MatchUserCell.self, forCellWithReuseIdentifier: matchUserCellId)
    
    navigationController?.navigationBar.isHidden = true
    UIView(backgroundColor: .white).add(to: view)
      .vLining(.top, to: view).hLining(to: view)
      .vLining(.bottom, .top)
    matchesNavBar.add(to: view).vLining(.top).hLining()
    matchesNavBar.delegate = self
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
      self?.fetchMatchUsers()
      self?.fetchRecentMessages()
    }
  }
  
  private func fetchMatchUsers() {
    db.fetchMatches {
      [weak self, weak cv = self.matchUserGalleryCell.collectionView] matches, error in
      guard let self = self else { return }
      if let error = error {
        print("fetching matches error", error)
        return
      }
      print("successfully fetch matches: ", matches!)
      self.matchUsers = matches ?? []
      cv?.reloadData()
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
      recentMessages.forEach({ self.cache.put(value: $0) })
      self.messageUserId = self.cache.allKeys()
      self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
    }
  }
 
  @objc private func handleDismiss() {
    navigationController?.popViewController(animated: true)
  }
  
  private func recentMessageFor(_ indexPath: IndexPath) -> RecentMessage? {
    cache.get(key: messageUserId[indexPath.item])
  }
  
  private func presentChatLog(withMatchUser matchUser: IdentifiableUser) {
    let chatLogController = ChatLogController(match: matchUser, current: user)
    navigationController?.pushViewController(chatLogController, animated: true)
  }
}


extension MatchesController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let recentMessage = recentMessageFor(indexPath) else { return }
    presentChatLog(withMatchUser: recentMessage)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let containerView = UIView()
    containerView.backgroundColor = tableView.backgroundColor
    let titleLabel = UILabel()
    titleLabel.text = section == 0 ? "Matches" : "Messages"
    titleLabel.textColor = UIColor(rgb: (255, 98, 103))
    titleLabel.add(to: containerView).filling(containerView, edgeInsets: .init(8, 16))
    return containerView
  }
  
}


extension MatchesController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 0 ? 1 : messageUserId.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 { return matchUserGalleryCell }
    let cell = tableView.dequeueReusableCell(withIdentifier: RecentMessageCellId, for: indexPath)
    as! RecentMessageCell
    let recentMessage = recentMessageFor(indexPath)!
    let uid = recentMessage.uid
    cell.uid = uid
    cell.message = recentMessage.text
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
  
}


extension MatchesController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 80, height: collectionView.bounds.height)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    presentChatLog(withMatchUser: matchUsers[indexPath.item])
  }
  
}


extension MatchesController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return matchUsers.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: matchUserCellId, for: indexPath) as! MatchUserCell
    let uid = matchUsers[indexPath.item].uid
    cell.uid = uid
    let (name, imageUrl) = db.matchUserInfo(for: uid)
    if imageUrl == nil {
      // hit the placeholder, means the data is being fetched, so register to the db
      // so that when the data arrived the cell will be notified
      db.registerMatchUserCell(cell)
    } else {
      cell.setUsername(name, imageUrl: imageUrl)
    }
    // once reach the last item, and there are more matches to fetch, fetch them
    if indexPath.item == matchUsers.count - 1 && hasMoreMatches {
      db.fetchMatches {
        [weak self, weak cv = collectionView] (matchUsers, error) in
        if let error = error {
          print("fetch matches error: ", error)
        }
        guard let matchUsers = matchUsers else { return }
        if matchUsers.isEmpty {
          self?.hasMoreMatches = false
          return
        }
        self?.matchUsers.append(contentsOf: matchUsers)
        cv?.reloadData()
      }
    }
    return cell
  }
  
}


extension MatchesController: MatchesNavBarDelegate {
  func didTappedBackButton() { handleDismiss() }
}
