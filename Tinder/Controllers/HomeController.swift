//
//  HomeController.swift
//  Tinder
//
//  Created by Gin Imor on 3/21/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UINib {
  static func viewWithName(_ nibName: String) -> UIView {
    UINib(nibName: nibName, bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
  }
}

class HomeController: UIViewController {

  var cardViewModel = CardViewModel()
  
  var modelTypes: [CardModel] = []
  
  let containerView = UINib.viewWithName("HomeView") as! HomeView
  
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
  }
  
  private func fetchUsers() {
    TinderFirebaseService.fetchUserMetaData(nextUserHandler: { (user) in
      self.modelTypes.append(user)
    }) { (error) in
      guard error == nil else {
        print("fetch users error: \(String(describing: error))")
        return
      }
      self.setupCardDeckView()
    }
  }
  
  fileprivate func setupCardDeckView() {
    let cardDeckView = containerView.cardDeckView!
    // zPosition take effect when the views are in the same level
    cardDeckView.layer.zPosition = 10
    modelTypes.forEach { (modelType) in
      let cardView = UINib.viewWithName("CardView") as! CardView
      cardViewModel.setModel(modelType)
      cardViewModel.configure(cardView)
      cardDeckView.addSubview(cardView)
      cardView.pinToSuperviewEdges()
    }
  }
  
  @objc func handleSettings() {
    let registration = RegistrationController()
    present(registration, animated: true)
  }
  
}

