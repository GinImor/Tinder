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

  var cardViewModel = CardViewModel()
  
  var modelTypes: [CardModel] = []
  
  let containerView = UINib.viewWithName("HomeView") as! HomeView
  var cardDeckView: UIView { containerView.cardDeckView! }
  
  var lastFetchedUser: User?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
    fetchUsers()
  }
  
  private func setupViews() {
    view.backgroundColor = .systemBackground
    containerView.frame = view.bounds
    view.addSubview(containerView)
    containerView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
    containerView.didTapRefresh = {
      self.handleRefresh()
    }
    // zPosition take effect when the views are in the same level
    cardDeckView.layer.zPosition = 10
  }
  
  private func handleRefresh() {
    fetchUsers()
  }
  
  private func fetchUsers() {
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Loading"
    hud.show(in: view)
    TinderFirebaseService.fetchUserMetaData(
      startingUid: lastFetchedUser?.uid,
      nextUserHandler: { (user) in
        self.modelTypes.append(user)
        self.lastFetchedUser = user
        self.createCardViewWithModelType(user)
    }) { (error) in
      hud.dismiss()
      guard error == nil else {
        print("fetch users error: \(String(describing: error))")
        return
      }
      print("successfully fetched users")
    }
  }
  
  fileprivate func createCardViewWithModelType(_ modelType: CardModel) {
    let cardView = UINib.viewWithName("CardView") as! CardView
    cardViewModel.setModel(modelType)
    cardViewModel.configure(cardView)
    cardDeckView.addSubview(cardView)
    cardDeckView.sendSubviewToBack(cardView)
    cardView.pinToSuperviewEdges()
  }
  
  fileprivate func fillUpCardDeckView() {
    modelTypes.forEach { (modelType) in
      createCardViewWithModelType(modelType)
    }
  }
  
  @objc func handleSettings() {
    let registration = RegistrationController()
    present(registration, animated: true)
  }
  
}

