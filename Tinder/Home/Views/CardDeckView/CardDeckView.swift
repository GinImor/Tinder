//
//  CardDeckView.swift
//  Tinder
//
//  Created by Gin Imor on 10/30/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class CardDeckView: UIView {
  
  var cardDeckViewModel: CardDeckViewModel?
  
  private var cardViewsPool: Set<CardView> = []
  
  // the user might swipe the cards fast, and the card animate offscreen takes time,
  // so use lastCardIndex keep track of the real time last card index
  private var lastCardIndex = -1
  var lastCard: CardView? {
    lastCardIndex < 0 ? nil : subviews[lastCardIndex] as? CardView
  }
  
  // can't wait until removeCardView to decrease lastCardIndex, cause it takes time
  // to complete the swiping animation, after which to remove the card, it will be
  // inaccurate for the real time last card index
  func willSwipeCard(_ card: CardView) {
    lastCardIndex -= 1
    addCardView()
  }
  
  func removeCardView(_ view: CardView) {
    cardViewsPool.insert(view)
    view.isHidden = true
    view.prepareForReuse()
  }
  
  // can't remove all cards in subviews, cause the user might initiate a swiping animation
  // and at the same time tap refresh button, which calls removeCardViews immediately,
  // after the swiping animation card deck remove the card, which will be removed first in the
  // removeCardViews if remove all subviews, and reuse it immediately.
  // later, after the animation completes, the card will be removed again,
  func removeCardViews() {
    while lastCardIndex >= 0 {
      if let cardView = subviews[lastCardIndex] as? CardView {
        removeCardView(cardView)
        lastCardIndex -= 1
      }
    }
  }
  
  func refresh(with models: [CardModel]) {
    removeCardViews()
    cardDeckViewModel?.cardModels = models
    for _ in 0..<2 { addCardView() }
  }
  
  func addCardView() {
    guard let cardModel = cardDeckViewModel?.nextCardModel else { return }
    lastCardIndex += 1
    let cardView: CardView
    if cardViewsPool.isEmpty {
      // use nib to create CardView will trigger SwipingPhotosController viewDidLoad
      cardView = CardView()
      cardView.add(to: self).filling(self)
      cardView.cardViewModel = CardViewModel(cardModel: cardModel)
      cardView.delegate = cardDeckViewModel?.cardViewDelegate
    } else {
      cardView = cardViewsPool.popFirst()!
      let viewModel = cardView.cardViewModel
      // view model switch to the new model and trigger the property observer
      viewModel?.switchToCardModel(cardModel)
      cardView.cardViewModel = viewModel
      cardView.isHidden = false
    }
    insertSubview(cardView, at: 0)
  }
  
  func rewind() {
    refresh(with: cardDeckViewModel?.cardModels ?? [])
  }
  
}
