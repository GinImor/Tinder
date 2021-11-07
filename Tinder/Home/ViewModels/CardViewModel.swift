//
//  CardViewModel.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

protocol CardModel: IdentifiableUser {
  var displayName: String { get }
  var attributedString: NSAttributedString { get }
  var textAlignment: NSTextAlignment { get }
  var introduction: NSAttributedString? { get }
  var validImageUrls: [String] { get }
}

extension User: CardModel {
  
  var displayName: String { name }
  
  var attributedString: NSAttributedString {
    let nameAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
    let ageAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .footnote)]
    let professionAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
    let ageString = age == nil ? "" : "  \(age!)\n"
    let professionString = "\(profession ?? "")"
    let result = NSMutableAttributedString(string: name, attributes: nameAttributes)
    result.append(NSAttributedString(string: ageString, attributes: ageAttributes))
    result.append(NSAttributedString(string: professionString, attributes: professionAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .left }
  
  var introduction: NSAttributedString? {
    guard let bio = bio else { return nil }
    let font = UIFont.preferredFont(forTextStyle: .body) // UIFont(name: "Avenir-Medium", size: 16) ??
    return NSAttributedString(string: bio, attributes: [.font: font, .foregroundColor: UIColor.systemGray])
  }
  
  var validImageUrls: [String] { imageUrls.compactMap { $0 } }
}

extension Advertiser: CardModel {
  
  var uid: String { "" }
  
  var displayName: String { title }

  var attributedString: NSAttributedString {
    let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .black)]
    let brandAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]
    let result = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
    result.append(NSAttributedString(string: brand, attributes: brandAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .center }
  
  var introduction: NSAttributedString? { nil }
  
  var validImageUrls: [String] { [posterImageName] }
}

class CardViewModel {
  
  var uid: String { cardModel.uid }
  
  // being set for reuse in home by calling CardDeckView.dequeReusableCardView
  var cardModel: CardModel
  
  private(set) var imageUrls: [String] = []
  var currentImageIndex: Int {
    get {
      isHome ? homeCardIndex : detailCardIndex
    }
    set {
      if isHome { homeCardIndex = newValue }
      else { detailCardIndex = newValue }
    }
  }

  private var invalidCardIndex = 0
  private var homeCardIndex = 0
  private var detailCardIndex = 0
  private(set) var isHome = true

  var attributedString: NSAttributedString {
    cardModel.attributedString
  }
  
  var textAlignment: NSTextAlignment {
    cardModel.textAlignment
  }
  
  var introduction: NSAttributedString? {
    cardModel.introduction
  }
  
  var firstImageUrl: String? {
    imageUrls.first
  }
  
  var currentImageUrl: String? {
    urlsCount > 0 ? imageUrls[currentImageIndex] : nil
  }
  
  var urlsCount: Int {
    imageUrls.count
  }
  
  init(cardModel: CardModel) {
    self.cardModel = cardModel
    imageUrls = cardModel.validImageUrls
  }
  
  func switchScenario() {
    isHome.toggle()
  }
  
  func switchToCardModel(_ cardModel: CardModel) {
    self.cardModel = cardModel
    invalidCardIndex = homeCardIndex
    imageUrls = cardModel.validImageUrls
    homeCardIndex = 0
    detailCardIndex = 0
    isHome = true
  }
  
  func configureBarIndicators(_ indicators: UIStackView!, addIndicator: () -> Void) {
    indicators.isHidden = true
    // only if there are more than one image show the indicators
    guard urlsCount > 1 else { return }
    let viewsCount = indicators.arrangedSubviews.count
    // the diff between the number of indicators need to be shown and the current
    // number of indicators that existed
    var diff = urlsCount - viewsCount
    var minCount = min(urlsCount, viewsCount)
    // if don't have enough indicators, create the correct amount
    while diff > 0 {
      addIndicator()
      diff -= 1
    }
    // now have enough indicators, need to show the correct amount of previously
    // existing indicators, originally, need to show number of urlsCount indicators
    // when urlsCount <= viewsCount, but when urlsCount > viewsCount, cause the new added
    // indicators are shown by default, only need to show number of viewsCount
    while minCount > 0 {
      minCount -= 1
      indicators.arrangedSubviews[minCount].isHidden = false
    }
    // original is set the 0 index backgroundColor, why set the currentImageIndex
    // in home initial set up or being reused, is 0
    // for the same card, one time switch to user detail, is 0, but again, is not
    indicators.arrangedSubviews[currentImageIndex].backgroundColor = .white
    indicators.isHidden = false
  }
  
  func enableCurrentBarIndicator(_ indicators: UIStackView!) {
    indicators.arrangedSubviews[currentImageIndex].backgroundColor = .white
  }
  
  func disableCurrentBarIndicator(_ indicators: UIStackView!) {
    indicators.arrangedSubviews[currentImageIndex].backgroundColor = .barDefaultColor
  }

  @discardableResult
  func nextCard(toRight: Bool) -> Int? {
    guard urlsCount > 0 else { return nil }
    let originalIndex = currentImageIndex
    advanceImageIndex(byStep: toRight ? 1 : -1)
    return originalIndex == currentImageIndex ? nil : currentImageIndex
  }
  
  func rewindIndex(for index: Int, add: Int) -> Int {
    ((index + add) % urlsCount + urlsCount) % urlsCount
  }
  
  func oneWayIndex(for index: Int, add: Int) -> Int {
    max(0, min(urlsCount - 1, index + add))
  }
  
  private func advanceImageIndex(byStep step: Int) {
    if isHome {
      // if in the home, rewind the index
      currentImageIndex = rewindIndex(for: homeCardIndex, add: step)
    } else {
      // if in the detail, make sure 0 <= result <= urlsCount - 1
      currentImageIndex = oneWayIndex(for: detailCardIndex, add: step)
    }
  }
  
}
