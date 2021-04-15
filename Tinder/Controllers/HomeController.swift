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
      TinderFirebaseService.fetchUsersBetweenAgeRange(
        minAge: user.minSeekingAge,
        maxAge: user.maxSeekingAge,
        nextUserHandler: { [weak self] user in
          self?.modelTypes.append(user)
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
  }
  
  let hud: JGProgressHUD = {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Loading..."
    return hud
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
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
    // zPosition take effect when the views are in the same level
    cardDeckView.layer.zPosition = 10
  }
  
  private func handleDislike() {
    swipeCardToRight(false)
  }
  
  private func handleLike() {
    swipeCardToRight(true)
  }
  
  private func swipeCardToRight(_ right: Bool) {
    if lastCardIndex > -1 && lastCardIndex < cardDeckView.subviews.count {
      let currentCard = cardDeckView.subviews[lastCardIndex] as! CardView
      lastCardIndex -= 1
      UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6
        , initialSpringVelocity: 0.0, options: [], animations: {
        currentCard.swipeToRight(right)
      }, completion: { (_) in
        currentCard.transform = .identity
        currentCard.removeFromSuperview()
      })
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
  
  func willRemoveCard(_ view: CardView) {
    lastCardIndex -= 1
  }
}