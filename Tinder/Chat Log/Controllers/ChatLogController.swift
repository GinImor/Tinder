//
// ChatLogController.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import CoreData
import GILibrary

class ChatLogController: UICollectionViewController {
  
  private let fetchSize = 14
  
  private let cellId = "cellId"
  
  private var match: Match
  
  private let messageNavBar: MessageNavBar
  private let chatLogInputAccessoryView = TextViewInputAccessoryView()
  
  private var currentUser: User?
  
  private var cursor = 0
  
  private var keyboardObserver: NSObjectProtocol?
  
  override var canBecomeFirstResponder: Bool { true }
  override var inputAccessoryView: UIView? { chatLogInputAccessoryView }
  
  private var insertingItems = [Int]()
  private var refreshCompletionBlock: (() -> Void)?
  
  private lazy var calculatingCell = ChatLogCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
  
  lazy var fetchedResultsController: NSFetchedResultsController<Message> = {
    let fetchRequest = Message.fetchRequest()
    fetchRequest.fetchBatchSize = fetchSize
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Message.creationDate), ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "chatRoomId == %@", match.localChatRoomId)
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                        managedObjectContext: coreDataStack.mainContext,
                                        sectionNameKeyPath: nil,
                                        cacheName: nil)
    frc.delegate = self
    return frc
  }()
  
  private var ops: [BlockOperation] = []
  
  deinit {
    for o in ops { o.cancel() }
    ops.removeAll()
  }
  
  
  init(match: Match, current: User?) {
    self.match = match
    self.currentUser = current
    self.messageNavBar = MessageNavBar(match: match)
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
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupObservers()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    if isMovingFromParent {
      db.removeMessagesListener()
      if let observer = keyboardObserver {
        NotificationCenter.default.removeObserver(observer)
      }
    }
  }
  
  func setupViews() {
    collectionView.backgroundColor = .white
    
    collectionView.keyboardDismissMode = .interactive
    collectionView.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
    
    collectionView.refreshControl = UIRefreshControl()
    collectionView.refreshControl?.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    
    messageNavBar.backButton.addTarget(self, action: #selector(handleDismiss))
    chatLogInputAccessoryView.didTappedSend = { [unowned self] button in self.handleSend(button) }
  }
  
  private func setupLayout() {
    UIView(backgroundColor: .white).add(to: view)
      .hLining(to: view).vLining(.top, to: view).vLining(.bottom, .top)
    messageNavBar.add(to: view).vLining(.top).hLining()
    messageNavBar.layoutIfNeeded()
    let fittingSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
    let navBarHeight = messageNavBar.systemLayoutSizeFitting(fittingSize).height
    collectionView.contentInset = .init(top: navBarHeight + 16, left: 0, bottom: 16, right: 0)
    collectionView.verticalScrollIndicatorInsets.top = navBarHeight
  }
  
  private func fetchData() {
    try? fetchedResultsController.performFetch()
    // cursor initially is -1,
    if let count = fetchedResultsController.fetchedObjects?.count, count > 0 {
      cursor = max(count - fetchSize, 0)
    }
    db.listenToMessages(from: match.cloudChatRoomId) { [weak self] error in
      if let error = error {
        print("fetch messages error", error)
        return
      }
      print("successfully fetch messages")
      self?.scrollToLastItem()
    }
  }
  
  private func setupObservers() {
    keyboardObserver = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardDidShowNotification,
      object: nil, queue: .main) {
        [weak self] _ in self?.scrollToLastItem()
    }
  }

  @objc private func handleDismiss() {
    navigationController?.popViewController(animated: true)
  }
  
  private func handleSend(_ button: UIButton) {
    guard let text = chatLogInputAccessoryView.text,
          !text.isEmpty,
          let currentUser = currentUser else { return }
    button.isEnabled = false
    chatLogInputAccessoryView.text = ""
    chatLogInputAccessoryView.showPlaceholder()
    db.uploadMessage(
      text, from: currentUser.uid, to: match.uid, chatRoomId: match.cloudChatRoomId) { error in
      // no matter succeeded or not, enable the send button
      button.isEnabled = true
      if let error = error {
        print("store message error", error)
        return
      }
      print("successfully store message")
    }
  }

  @objc func handleRefresh() {
    if cursor <= 0 {
      refreshCompletionBlock = { [unowned self] in
        self.collectionView.refreshControl?.endRefreshing()
      }
    } else {
  //    var i = cursor - 1
  //    var contentOffsetY = -collectionView.safeAreaInsets.top

      let newCursor = max(cursor - fetchSize, 0)
  //    while i >= newCursor {
  //      contentOffsetY += 10
  //      i -= 1
  //    }
      
      refreshCompletionBlock = { [weak self] in
        self?.collectionView.refreshControl?.endRefreshing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self?.cursor = newCursor
          UIView.performWithoutAnimation {
            self?.collectionView.reloadData()
    //        self.collectionView.setContentOffset(CGPoint(x: 0, y: contentOffsetY), animated: false)
          }
        }
      }
    }
    if !collectionView.isTracking { endRefreshing() }
  }
  
  private func scrollToLastItem() {
    guard let lastIndex = fetchedResultsController.fetchedObjects?.count,
        lastIndex > 0 else { return }
    let indexPath: IndexPath = [0, lastIndex - cursor - 1]
    collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
  }
  
  private func endRefreshing() {
    refreshCompletionBlock?()
    refreshCompletionBlock = nil
  }
  
  private func globalIndexPathFor(_ indexPath: IndexPath) -> IndexPath {
    IndexPath(item: indexPath.item + cursor, section: indexPath.section)
  }
  
  private func localIndexPathFor(_ indexPath: IndexPath) -> IndexPath {
    IndexPath(item: indexPath.item - cursor, section: indexPath.section)
  }
  
}


extension ChatLogController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return (fetchedResultsController.fetchedObjects?.count ?? cursor) - cursor
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCell
    cell.item = fetchedResultsController.object(at: globalIndexPathFor(indexPath))
    return cell
  }
  
}


extension ChatLogController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    calculatingCell.item = fetchedResultsController.object(at: globalIndexPathFor(indexPath))
    calculatingCell.layoutIfNeeded()
    let fittingSize = CGSize(width: collectionView.bounds.width, height: 1000)
    let cellHeight = calculatingCell.systemLayoutSizeFitting(fittingSize).height
    return CGSize(width: collectionView.bounds.width, height: cellHeight)
  }
}


extension ChatLogController: NSFetchedResultsControllerDelegate {
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    // delete and reload index paths is relative to the original data set,
    // insert is relative to the updated version. also, this app doesn't allow
    // user to delete message before the cursor, so is safe not check the indexPath,
    // otherwise, need to check if indexPath < cursor, if is the case, then aggregate
    // the number of it, update cursor based on insert and delete, and decide
    // what to insert in collection view
    switch type {
    case .insert:
      insertingItems.append(newIndexPath!.item)
    case .delete:
      let indexPath = localIndexPathFor(indexPath!)
      ops.append(BlockOperation(block: { [weak self] in
        self?.collectionView.deleteItems(at: [indexPath])
      }))
    case .update:
      guard indexPath!.item >= cursor else { return }
      let indexPath = localIndexPathFor(indexPath!)
      ops.append(BlockOperation(block: { [weak self] in
        self?.collectionView.reloadItems(at: [indexPath])
      }))
    default: break
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    insertingItems.sort()
    var i = insertingItems.count
    for (j, item) in insertingItems.enumerated() {
      if item >= cursor { i = j; break }
      cursor += 1
    }
    collectionView.performBatchUpdates({ () -> Void in
      for op: BlockOperation in self.ops { op.start() }
      while i < self.insertingItems.count {
        self.collectionView.insertItems(at: [[0, self.insertingItems[i] - cursor]])
        i += 1
      }
    }, completion: { (finished) -> Void in
      self.ops.removeAll()
      self.insertingItems = []
    })
  }
  
}


// Scroll View Delegate

extension ChatLogController {
  
  override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if refreshCompletionBlock != nil { endRefreshing() }
  }
  
}
