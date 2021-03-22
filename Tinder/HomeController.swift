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

  var users: [User] = [
    User(name: "Joey", age: 27, profession: "actor", imageName: ""),
    User(name: "Ross", age: 28, profession: "professor", imageName: "")
  ]
  
  let containerView = UINib.viewWithName("HomeView") as! HomeView
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
  }

  private func setupViews() {
    view.backgroundColor = .systemBackground
    containerView.frame = view.bounds
    view.addSubview(containerView)
    
    let cardDeckView = containerView.cardDeckView!
    // zPosition take effect when the views are in the same level
    cardDeckView.layer.zPosition = 10
    users.forEach { (user) in
      let cardView = UINib.viewWithName("CardView") as! CardView
      cardView.nameLabel.text = user.name
      cardView.ageLabel.text = "\(user.age)"
      cardView.professionLabel.text = user.profession
      cardDeckView.addSubview(cardView)
      cardView.pinToSuperviewEdges()
    }
  }
  

  
}

