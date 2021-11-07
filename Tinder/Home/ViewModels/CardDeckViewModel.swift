//
//  CardDeckViewModel.swift
//  Tinder
//
//  Created by Gin Imor on 11/5/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class CardDeckViewModel {
  
  var nextCardIndex = 0
  var cardModels: [CardModel] = [] {
    didSet { nextCardIndex = 0 }
  }
  
  weak var cardViewDelegate: CardViewDelegate?
  
  var nextCardModel: CardModel? {
    if nextCardIndex < cardModels.count {
      defer { nextCardIndex += 1 }
      return cardModels[nextCardIndex]
    }
    return nil
  }
  
}
