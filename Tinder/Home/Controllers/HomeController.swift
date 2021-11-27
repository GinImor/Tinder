//
//  HomeController.swift
//  Tinder
//
//  Created by Gin Imor on 3/21/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD
import GILibrary

extension UINib {
  static func viewWithName(_ nibName: String) -> UIView {
    UINib(nibName: nibName, bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
  }
}

class HomeController: UIViewController {

  var user: User?
  
  // once fetched certain user's swiped users, doesn't need to fetch again,
  // cause the app will keep the swiped users up to date, but once log out and
  // log in again, need to fetch the newest swiped users
  private var hasFetchedSwipedUsers = false
  
  @IBOutlet weak var topStackView: UIStackView! {
    didSet {
      topStackView.isLayoutMarginsRelativeArrangement = true
      topStackView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
    }
  }

  @IBOutlet weak var cardDeckView: CardDeckView! {
    didSet {
      cardDeckView.cardDeckViewModel = CardDeckViewModel()
      cardDeckView.cardDeckViewModel?.cardViewDelegate = self
      cardDeckView.layer.zPosition = 10
    }
  }

  private let hud = JGProgressHUD.new("Loading...")
  
  private var swipedUsers: [String: Bool] = [:]
  
  private var userDetailsController: UserDetailsController!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupUserBasedObject()
    fetchData()
    print("view fraome", view.bounds)
  }
  
  // promise in the Home, there is always a user logged in
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // there hasn't user logged in, present the registration page
    // user just open the app at the logged out state or logged out from the settings
    if !auth.hasCurrentUser {
      presentRegistration()
    }
  }
  
  private func setupViews() {
    navigationController?.navigationBar.isHidden = true
    view.backgroundColor = .systemBackground
  }
  
  private func setupUserBasedObject() {
    // every time the firestore manager fetch current user, home will get updated
    db.userBasedObject = self
  }
  
  // first fetch the current user,
  // there are three cases this method gets called
  // one is user lauch the app, call it in the viewDidLoad
  // one is after logging in
  // one is from the fetchQualifiedUsers method which is called by refresh with no user
  // back from saving settings guarantees has a user, so it fetch qualified users directly
  private func fetchData() {
    prepareForFetchingUsers()
    db.fetchCurrentUser { [weak self] user, error in
      if let error = error {
        self?.hud.dismiss()
        if let authError = error as? AuthError {
          if authError == .noResponse {
            auth.logout()
            self?.presentRegistration()
          }
        }
        print("fetch current user error:", error)
        return
      }
      guard let user = user else { return }
      self?.user = user
      self?.fetchQualifiedUsers()
    }
  }
  
  // called from fetchData, refresh or after saving settings
  private func fetchQualifiedUsers() {
    prepareForFetchingUsers()
    // make sure there is a user, if isn't, go fetch one first
    guard let user = self.user else { fetchData(); return }
    // has a user, go fetch the user's swiped users in order to filter
    var fetchError: Error?
    let dispatchGroup = DispatchGroup()
    if !hasFetchedSwipedUsers {
      dispatchGroup.enter()
      db.fetchSwipedUsers() {
        [weak self] swipedUsers, error in
        fetchError = error
        self?.swipedUsers = swipedUsers ?? [:]
        dispatchGroup.leave()
      }
    }
    dispatchGroup.notify(queue: .main) { [unowned self] in
      if let fetchError = fetchError {
        self.hud.dismiss()
        print("fetch swiped users error", fetchError)
        return
      }
      self.hasFetchedSwipedUsers = true
      // has swiped users, go fetch the qualified users
      db.fetchUsersBetweenAgeRange(
        minAge: user.minSeekingAge,
        maxAge: user.maxSeekingAge,
        swipedUsers: self.swipedUsers) { [unowned self] (newUsers, error) in
        self.hud.dismiss()
        guard error == nil else {
          print("fetch users error: \(String(describing: error))")
          return
        }
        print("successfully fetched users")
        guard let newUsers = newUsers else { return }
        self.cardDeckView.refresh(with: newUsers)
      }
    }
  }

  private func prepareForFetchingUsers() {
    if hud.isHidden {
      hud.show(in: view)
      cardDeckView.removeCardViews()
    }
  }

  private func uploadLikingStateOnCard(_ card: CardView, like: Bool) {
    let currUid = user!.uid
    db.setLikeStateForUid(currUid, on: card.uid, to: like) {
      [weak self] error in
      if let error = error { print("liking user error", error); return }
      // upload can be slow, in the meantime, user might change the account to something else
      // so need to check if the user is the same user that initiate the upload process
      // if not, doesn't present the match view, but the upload process need to be done
      guard let matchedCardModel = card.cardViewModel?.cardModel,
            let currentUser = self?.user, currUid == currentUser.uid else { return }
      self?.presentMatchView(matchedUser: matchedCardModel, currentUser: currentUser)
    }
  }
  
  private func presentMatchView(matchedUser: CardModel, currentUser: CardModel) {
    let matchView = MatchView(matchedUser: matchedUser, currentUser: currentUser)
    matchView.delegate = self
    matchView.add(to: view).filling(view).alpha = 0.0
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0,
                   initialSpringVelocity: 1.0, options: .curveEaseOut)
    { matchView.alpha = 1.0 }
  }

  @IBAction private func handleShowMatches() {
    let matches = MatchesController()
    navigationController?.pushViewController(matches, animated: true)
  }
  
  @IBAction private func handleDislike() { swipeCardToRight(false) }
  
  @IBAction private func handleLike() { swipeCardToRight(true) }
  
  @IBAction private func handleSuperLike() { swipeCardToRight(true) }
  
  @IBAction private func handleRefresh() {
//    fetchQualifiedUsers()
    cardDeckView.rewind()
  }

  @IBAction private func handleSettings() {
    let settings = SettingsController()
    settings.delegate = self
    let nav = UINavigationController(rootViewController: settings)
    nav.isModalInPresentation = true
    present(nav, animated: true)
  }
  
  private func swipeCardToRight(_ right: Bool) {
    guard let lastCard = cardDeckView.lastCard else { return }
    willSwipeCard(lastCard, toRight: right)
    lastCard.swipeToRight(right)
  }
  
  private func presentRegistration() {
    let registration = RegistrationController()
    registration.delegate = self
    let nav = UINavigationController(rootViewController: registration)
    nav.modalPresentationStyle = .fullScreen
    present(nav, animated: true)
  }
  
}


// home dispatch user object to settings, matches etc, and refresh based on user object
// infos, but at the time user object probably is nil cause the poor network, so after
// others fetch the current user successfully home should get one too, if can't fetch user
// simply dismiss the presented controller
extension HomeController: UserBasedObject {}


extension HomeController: SettingsControllerDelegate {
  
  func didSaveNewUser(_ newUser: User) {
    // if either the seeking age change, roll back to the begining
    // and fetch the new qualified users
    // if not change, just get the new user
    if user?.minSeekingAge != newUser.minSeekingAge ||
        user?.maxSeekingAge != newUser.maxSeekingAge {
      db.nullifyHomeDocSnapshot()
      fetchQualifiedUsers()
    }
    user = newUser
  }
  
  // if the presentation style of settings is .fullScreen, then in the viewDidAppear
  // will call the same method, just to be awared of, and if the style is default,
  // viewDidAppear won't be called
  func didLogOut() {
    presentRegistration()
  }
}


extension HomeController: LoginRegisterControllerDelegate {
  
  func didFinishedLoggingIn() {
    dismiss(animated: true)
    user = nil
    hasFetchedSwipedUsers = false
    db.nullifyHomeDocSnapshot()
    fetchData()
  }
}


extension HomeController: CardViewDelegate {
  
  func didTappedDetailArea(_ cardView: CardView) {
    if userDetailsController == nil {
      userDetailsController = UserDetailsController()
      userDetailsController.delegate = self
      userDetailsController.modalPresentationStyle = .fullScreen
    }
    cardView.cardViewModel.switchScenario()
    userDetailsController.cardViewModel = cardView.cardViewModel
    present(userDetailsController, animated: true)
  }
  
  func willSwipeCard(_ card: CardView, toRight: Bool) {
    uploadLikingStateOnCard(card, like: toRight)
    swipedUsers[card.uid] = toRight
    cardDeckView.willSwipeCard(card)
  }
  
  func didFinishedSwipingCard(_ card: CardView) {
    cardDeckView.removeCardView(card)
  }
}


extension HomeController: MatchViewDelegate {
  
  func didTappedSendMessageButton(matchUser: IdentifiableUser) {
    let chatLogController = ChatLogController(match: matchUser, current: user)
    navigationController?.pushViewController(chatLogController, animated: true)
  }
}

extension HomeController: UserDetailsControllerDelegate {
  
  func didTappedDislikeButton() { handleDislike() }
  
  func didTappedLikeButton() { handleLike() }
  
  func didTappedSuperLikeButton() { handleSuperLike() }
}
