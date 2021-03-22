//
//  CardViewModel.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CardViewModel {
  
  enum CardModelType {
    case user(User)
    case other
  }
  
  var cardModelType: CardModelType?
  
  func setModel(_ cardModelType: CardModelType) {
    self.cardModelType = cardModelType
  }
  
  private func populateView(_ cardView: CardView, withUser user: User) {
    cardView.nameLabel.text = user.name
    cardView.ageLabel.isHidden = false
    cardView.ageLabel.text = "\(user.age)"
    cardView.professionLabel.text = user.profession
    cardView.nameLabel.textAlignment = .left
    cardView.professionLabel.textAlignment = .left
  }
  
  func configure(_ cardView: CardView) {
    switch cardModelType {
    case let .user(user):
      populateView(cardView, withUser: user)
    default: ()
    }
   
  }
  
}
