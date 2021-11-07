//
// ChatLogController.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class ChatLogController: GIGridController<Message> {
  
  override var ItemCellClass: GIGridCell<Message>.Type? { return ChatLogCell.self }
  
  private var match: IdentifiableUser
  
  private let messageNavBar: MessageNavBar
  private let chatLogInputAccessoryView = TextViewInputAccessoryView()
  
  private var currentUser: User?
  
  private var keyboardObserver: NSObjectProtocol?
  
  override var canBecomeFirstResponder: Bool { true }
  override var inputAccessoryView: UIView? { chatLogInputAccessoryView }
  
  
  init(match: IdentifiableUser, current: User?) {
    self.match = match
    self.currentUser = current
    self.messageNavBar = MessageNavBar(match: match)
    super.init(flowLayout: UICollectionViewFlowLayout())
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
  
  override func setupViews() {
    super.setupViews()
    collectionView.alwaysBounceVertical = true
    collectionView.keyboardDismissMode = .interactive
    messageNavBar.backButton.addTarget(self, action: #selector(handleDismiss))
    chatLogInputAccessoryView.didTappedSend = { [unowned self] button in self.handleSend(button) }
  }
  
  override func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {
    // Setting it to any other value, like automaticSize, causes the collection view to query
    // each cell for its actual size using the cell’s preferredLayoutAttributesFitting(_:) method.
    flowLayout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 50)
    flowLayout.sectionInset = .init(16, 0)
  }
  
  private func setupLayout() {
    UIView(backgroundColor: .white).add(to: view)
      .hLining(to: view).vLining(.top, to: view).vLining(.bottom, .top)
    messageNavBar.add(to: view).vLining(.top).hLining()
    view.layoutIfNeeded()
    let navBarHeight = messageNavBar.frame.height
    collectionView.contentInset.top = navBarHeight
    collectionView.verticalScrollIndicatorInsets.top = navBarHeight
//    chatLogInputAccessoryView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 60)
  }
  
  private func fetchData() {
    db.listenToMessages(toUid: match.uid,
      nextMessageHandler: { [weak self] in
        self?.grid.append($0)
      },
      completion: { [weak self] error in
        if let error = error {
          print("fetch messages error", error)
          return
        }
        print("successfully fetch messages")
        self?.collectionView.reloadData()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
          DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            // scroll to the visible area
            strongSelf.collectionView.scrollToItem(
              at: [0, strongSelf.grid.count - 1], at: .top, animated: true)
          }
        }
      })
  }

  private func setupObservers() {
    keyboardObserver = NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { [weak self] _ in
      guard let strongSelf = self else { return }
      strongSelf.collectionView.scrollToItem(at: [0, strongSelf.grid.count - 1], at: .top, animated: true)
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
      text, from: currentUser.uid, to: match.uid) { error in
      // no matter succeeded or not, enable the send button
      button.isEnabled = true
      if let error = error {
        print("store message error", error)
        return
      }
      print("successfully store message")
    }
    db.uploadRecentMessage(
      text, from: currentUser.uid, to: match.uid) { error in
      if let error = error {
        print("store recent message error", error)
        return
      }
      print("successfully store recent message")
    }
  }

  override func additionalSetupForCell(_ cell: GIGridCell<Message>, indexPath: IndexPath) {
    let cell = cell as! ChatLogCell
    cell.width = collectionView.bounds.width
  }

}
