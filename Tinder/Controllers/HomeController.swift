//
//  HomeController.swift
//  Tinder
//
//  Created by Gin Imor on 3/21/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD

extension UINib {
  static func viewWithName(_ nibName: String) -> UIView {
    UINib(nibName: nibName, bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
  }
}

class HomeController: UIViewController {

  var modelTypes: [CardModel] = []
  
  let containerView = UINib.viewWithName("HomeView") as! HomeView
  var cardDeckView: UIView { containerView.cardDeckView! }
  
  var lastFetchedUser: User?
  var lastCardIndex = -1
  
  var user: User? {
    didSet {
      guard let user = user else { return }
      if hud.isHidden {
        hud.show(in: view)
        cardDeckView.subviews.forEach { $0.removeFromSuperview() }
      }
      fetchDataForUser(user)
    }
  }
  
  private func fetchDataForUser(_ user: User) {
    TinderFirebaseService.fetchSwipedUsers() { [weak self] swipedUsers, error in
      guard error == nil else {
        print("fetch swiped users error", error!)
        return
      }
      self?.swipedUsers = swipedUsers!
      TinderFirebaseService.fetchUsersBetweenAgeRange(
        minAge: user.minSeekingAge,
        maxAge: user.maxSeekingAge,
        nextUserHandler: { [weak self] user in
          guard let strongSelf = self, strongSelf.swipedUsers[user.uid] == nil else { return }
          strongSelf.modelTypes.append(user)
          strongSelf.createCardViewWithModelType(user)
        }) { [weak self] (error) in
        self?.hud.dismiss()
        guard error == nil else {
          print("fetch users error: \(String(describing: error))")
          return
        }
        print("successfully fetched users")
      }
    }
  }
  
  private var swipedUsers: [String: Bool] = [:]
  
  let hud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Loading..."
    return hud
  }()
  
  private var lastCard: CardView? {
    lastCardIndex < 0 ? nil : cardDeckView.subviews[lastCardIndex] as? CardView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    fetchQualifiedUsers()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !TinderFirebaseService.hasCurrentUser {
      let registration = RegistrationController()
      registration.delegate = self
      let nav = UINavigationController(rootViewController: registration)
      present(nav, animated: true)
    }
  }
  
  private func setupViews() {
    navigationController?.navigationBar.isHidden = true
    view.backgroundColor = .systemBackground
    containerView.frame = view.bounds
    view.addSubview(containerView)
    containerView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    containerView.didTapRefresh = {
      self.handleRefresh()
    }
    containerView.didTapLike = {
      self.handleLike()
    }
    containerView.didTapDislike = {
      self.handleDislike()
    }
    containerView.didTapMessages = {
      self.handleShowMatches()
    }
    // zPosition take effect when the views are in the same level
    cardDeckView.layer.zPosition = 10
  }
  
  private func handleShowMatches() {
    let matches = MatchesController()
    matches.user = user
    navigationController?.pushViewController(matches, animated: true)
  }
  
  private func handleDislike() {
    swipeCardToRight(false)
  }
  
  private func handleLike() {
    swipeCardToRight(true)
  }
  
  private func swipeCardToRight(_ right: Bool) {
    guard let lastCard = lastCard else { return }
    uploadLikingStatusForCard(card: lastCard, like: right)
    lastCardIndex -= 1
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6
      , initialSpringVelocity: 0.0, options: [], animations: {
      lastCard.swipeToRight(right)
    }, completion: { (_) in
      lastCard.transform = .identity
      lastCard.removeFromSuperview()
    })
  }
  
  private func uploadLikingStatusForCard(card: CardView, like: Bool) {
    TinderFirebaseService.likeUserWithUid(card.uid, like: like) { [weak self] isMatch, error in
      if let error = error {
        print("liking user error", error)
        return
      }
      guard isMatch else { return }
      print("successfully like user")
      guard let matchedCardModel = card.cardViewModel?.cardModel,
            let currentUser = self?.user else { return }
      self?.presentMatchView(matchedUser: matchedCardModel, currentUser: currentUser)
      self?.uploadMatches(currentUser, matchedCardModel)
    }
  }
  
  private func uploadMatches(_ userOne: CardModel, _ userTwo: CardModel) {
    TinderFirebaseService.storeMatches(userOne, userTwo) { error in
      if let error = error {
        print("store matches error", error)
        return
      }
      print("successfully store matches")
    }
  }
  
  private func presentMatchView(matchedUser: CardModel, currentUser: CardModel) {
    let matchView = MatchView(matchedUser: matchedUser, currentUser: currentUser)
    matchView.pinToSuperviewEdges(pinnedView: view)
    matchView.alpha = 0.0
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0
      , initialSpringVelocity: 1.0, options: .curveEaseOut
    ) {
      matchView.alpha = 1.0
    }
  }
  
  private func handleRefresh() {
    fetchUsers()
  }
  
  private func fetchUsers() {
    hud.show(in: view)
    TinderFirebaseService.fetchUserMetaData(
      startingUid: lastFetchedUser?.uid,
      nextUserHandler: { [weak self] (user) in
        self?.modelTypes.append(user)
        self?.lastFetchedUser = user
        self?.createCardViewWithModelType(user)
      }) { [weak self] (error) in
      self?.hud.dismiss()
      guard error == nil else {
        print("fetch users error: \(String(describing: error))")
        return
      }
      print("successfully fetched users")
    }
  }
  
  private func fetchQualifiedUsers() {
    hud.show(in: view)
    cardDeckView.subviews.forEach { $0.removeFromSuperview() }
    TinderFirebaseService.fetchCurrentUser { [weak self] user, error in
      if let error = error {
        self?.hud.dismiss()
        print("fetch current user error:", error)
        return
      }
      self?.user = user
    }
  }
  
  fileprivate func createCardViewWithModelType(_ modelType: CardModel) {
    let cardView = UINib.viewWithName("CardView") as! CardView
    let cardViewModel = CardViewModel(cardModel: modelType)
    cardView.cardViewModel = cardViewModel
    cardView.delegate = self
    cardDeckView.addSubview(cardView)
    cardDeckView.sendSubviewToBack(cardView)
    lastCardIndex += 1
    cardView.pinToSuperviewEdges()
  }
  
  fileprivate func fillUpCardDeckView() {
    modelTypes.forEach { (modelType) in
      createCardViewWithModelType(modelType)
    }
  }
  
  @objc func handleSettings() {
    let settings = SettingsController()
    settings.delegate = self
    let nav = UINavigationController(rootViewController: settings)
    present(nav, animated: true)
  }
  
}

extension HomeController: SettingsControllerDelegate {}

extension HomeController: LoginRegisterControllerDelegate {
  func didFinishedLoggingIn() {
    dismiss(animated: true)
    fetchQualifiedUsers()
  }
}

extension HomeController: CardViewDelegate {
  func didTappedDetailButton(_ model: CardViewModel) {
    let userDetailsController = UserDetailsController()
    userDetailsController.modalPresentationStyle = .fullScreen
    model.switchScenario()
    userDetailsController.cardViewModel = model
    present(userDetailsController, animated: true)
  }
  
  func willSwipeCard(_ view: CardView, toRight: Bool) {
    uploadLikingStatusForCard(card: view, like: toRight)
    lastCardIndex -= 1
  }
}
