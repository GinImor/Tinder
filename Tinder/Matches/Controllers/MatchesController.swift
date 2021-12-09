//
//  MatchesController.swift
//  Tinder
//
//  Created by Gin Imor on 11/26/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary
import CoreData

class MatchesController: UIViewController {

  var user: User?
  
  private let matchesNavBar = MatchesNavBar()
  
  private let RecentMessageCellId = "RecentMessageCellId"
  
  private let matchUserGalleryCell = UITableViewCell(style: .default, reuseIdentifier: nil)
  private var matchUserGalleryController: MatchUsersGalleryController!
  
  private weak var tableView: UITableView!
  
  lazy private var fetchedResultsController: NSFetchedResultsController<Message> = {
    let fetchRequest = Message.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.creationDate), ascending: false)]
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: tempDataStack.mainContext,
                                         sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self
    return frc
  }()
  
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
      db.removeMatchesListener()
      db.removeRecentMessagesListener()
      tempDataStack.deleteAll()
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
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.sectionInset = .init(0, 16)
    flowLayout.scrollDirection = .horizontal
    matchUserGalleryController = MatchUsersGalleryController(collectionViewLayout: flowLayout)
    matchUserGalleryController.didTappedMatchUser = { [unowned self] matchUser in
      self.presentChatLog(for: matchUser.chatRoomId)
    }
    addChild(matchUserGalleryController)
    let cellContentView = matchUserGalleryCell.contentView
    matchUserGalleryController.view.add(to: cellContentView)
      .filling(cellContentView, edgeInsets: .init(8, 0))
    matchUserGalleryController.didMove(toParent: self)
    
    let tv = UITableView()
    tv.delegate = self
    tv.dataSource = self
    tv.backgroundColor = .white
    tv.register(RecentMessageCell.self, forCellReuseIdentifier: RecentMessageCellId)
    tv.separatorStyle = .none
    tv.add(to: view).filling(view)
    tableView = tv
    
    navigationController?.navigationBar.isHidden = true
    UIView(backgroundColor: .white).add(to: view)
      .vLining(.top, to: view).hLining(to: view)
      .vLining(.bottom, .top)
    matchesNavBar.add(to: view).vLining(.top).hLining()
    matchesNavBar.delegate = self
  }
  
  private func fetchData() {
    try? fetchedResultsController.performFetch()
    db.fetchCurrentUserIfNecessary {
      [weak self] user, error in
      if let error = error {
        print("fetch current user error", error)
        // if can't get a user, dismiss back to home
        self?.handleDismiss()
        return
      }
      self?.user = user
      self?.matchUserGalleryController.fetchMatchUsers()
      self?.fetchRecentMessages()
    }
  }
  
 
  private func fetchRecentMessages() {
    db.listenToRecentMessages { error in
      // listener observes the recent message updates in firestore
      if let error = error {
        print("fetch recent messages error", error)
        return
      }
      print("successfully fetch recent messages")
    }
  }
 
  @objc private func handleDismiss() {
    navigationController?.popViewController(animated: true)
  }
  
  private func presentChatLog(for localChatRoomId: String?) {
    guard let localChatRoomId = localChatRoomId else { return }
    let chatLogController = ChatLogController(match: Match(localChatRoomId), current: user)
    navigationController?.pushViewController(chatLogController, animated: true)
  }
  
  private func globalized(_ indexPath: IndexPath) -> IndexPath {
    [0, indexPath.row]
  }
  
  private func localized(_ indexPath: IndexPath) -> IndexPath {
    [1, indexPath.row]
  }
  
}


extension MatchesController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let message = fetchedResultsController.object(at: globalized(indexPath))
    guard let cloudChatRoomId = message.chatRoomId else { return }
    presentChatLog(for: cloudChatRoomId + " " + message.chattingUid)
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
    return section == 0 ? 1 : (fetchedResultsController.fetchedObjects?.count ?? 0)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 { return matchUserGalleryCell }
    let cell = tableView.dequeueReusableCell(withIdentifier: RecentMessageCellId, for: indexPath)
    as! RecentMessageCell
    let recentMessage = fetchedResultsController.object(at: globalized(indexPath))
    let uid = recentMessage.chattingUid
    cell.uid = uid
    cell.message = recentMessage.content
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


// MARK: - Fetched Results Controller Delegate

extension MatchesController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [localized(newIndexPath!)], with: .automatic)
    case .delete:
      tableView.deleteRows(at: [localized(indexPath!)], with: .automatic)
    case .update:
      tableView.reloadRows(at: [localized(indexPath!)], with: .automatic)
    case .move:
      tableView.deleteRows(at: [localized(indexPath!)], with: .automatic)
      tableView.insertRows(at: [localized(newIndexPath!)], with: .automatic)
    @unknown default:
      print("Unexpected NSFetchedResultsChangeType")
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  
}


extension MatchesController: MatchesNavBarDelegate {
  func didTappedBackButton() { handleDismiss() }
}
