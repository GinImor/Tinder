//
// ChatLogController.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: CollectionController<ChatLogCell, Message> {
  
  private let match: MatchUser
  
  private let messageNavBar: MessageNavBar
  private let chatLogInputAccessoryView = TextViewInputAccessoryView()
  
  var currentUser: User?
  
  private var listener: ListenerRegistration?
  private var keyboardObserver: NSObjectProtocol?
  
  init(match: MatchUser, current: User?) {
    self.match = match
    self.currentUser = current
    self.messageNavBar = MessageNavBar(match: match)
    super.init()
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
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isMovingFromParent {
      listener?.remove() }
    if let observer = keyboardObserver {
      NotificationCenter.default.removeObserver(observer)
    }
  }
 
  private func setupObservers() {
    keyboardObserver =  NotificationCenter.default.addObserver(
      forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { [weak self] _ in
      guard let strongSelf = self else { return }
      strongSelf.collectionView.scrollToItem(at: [0, strongSelf.items.count - 1], at: .bottom, animated: true)
    }
  }
  
  override func setupFlowLayout(_ flowLayout: UICollectionViewFlowLayout) {
    flowLayout.estimatedItemSize = CGSize(width: collectionView.bounds.width, height: 50)
    flowLayout.sectionInset.top = 16
  }
  
  override func setupViews() {
    super.setupViews()
    collectionView.alwaysBounceVertical = true
    collectionView.keyboardDismissMode = .interactive
    messageNavBar.backButton.addTarget(self, action: #selector(handleDismiss))
    chatLogInputAccessoryView.didTappedSend = { [unowned self] button in self.handleSend(button) }
  }
  
  private func fetchData() {
    listener = TinderFirebaseService.fetchMessages(toUid: match.uid,
      nextMessageHandler: { [weak self] in
        self?.items.append($0)
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
            strongSelf.collectionView.scrollToItem(at: [0, strongSelf.items.count - 1], at: .bottom, animated: true)
          }
        }
      })
  }
  
  override var items: [Message] {
    didSet {
      print("items count", items.count)
    }
  }
  
  private func handleSend(_ button: UIButton) {
    guard let text = chatLogInputAccessoryView.text,
      let currentUser = currentUser else { return }
    button.isEnabled = false
    TinderFirebaseService.storeMessage(text, toUid: match.uid) { [weak self] error in
      button.isEnabled = true
      if let error = error {
        print("store message error", error)
        return
      }
      print("successfully store message")
      self?.chatLogInputAccessoryView.text = ""
      self?.chatLogInputAccessoryView.showPlaceholder()
    }
    TinderFirebaseService.storeRecentMessage(
      text, currentUser: currentUser, chattingUser: match) { error in
      if let error = error {
        print("store recent message error", error)
        return
      }
      print("successfully store recent message")
    }
  }
  
  private func setupLayout() {
    UIView.new(backgroundColor: .white).add(to: view)
      .filling(view) { $0[2].isActive = false }
      .vLining(.bottom, .top)
    messageNavBar.add(to: view).vLining(.top).hLining(.horizontal)
    view.layoutIfNeeded()
    let navBarHeight = messageNavBar.frame.height
    collectionView.contentInset.top = navBarHeight
    collectionView.verticalScrollIndicatorInsets.top = navBarHeight
    chatLogInputAccessoryView.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width
      , height: 50)
  }
  
  @objc func handleDismiss() {
    navigationController?.popViewController(animated: true)
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) ->
    UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! ChatLogCell
    cell.width = collectionView.bounds.width
    return cell
  }
  
  override var canBecomeFirstResponder: Bool { true }
  override var inputAccessoryView: UIView? { chatLogInputAccessoryView }
}
