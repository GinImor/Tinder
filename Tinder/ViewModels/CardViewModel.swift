//
//  CardViewModel.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

protocol CardModel {
  var uid: String { get }
  var displayName: String { get }
  var attributedString: NSAttributedString { get }
  var textAlignment: NSTextAlignment { get }
  var validImageUrls: [String] { get }
}

extension User: CardModel {
  
  var displayName: String { name }
  
  var attributedString: NSAttributedString {
    let nameAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
    let ageAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
    let professionAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
    let ageString = age == nil ? "" : "  \(age!)\n"
    let professionString = "\(profession ?? "")"
    let result = NSMutableAttributedString(string: name, attributes: nameAttributes)
    result.append(NSAttributedString(string: ageString, attributes: ageAttributes))
    result.append(NSAttributedString(string: professionString, attributes: professionAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .left }
  
  var validImageUrls: [String] { imageUrls.compactMap { $0 } }
}

extension Advertiser: CardModel {
  
  var displayName: String { title }
  
  var uid: String { "" }
  
  var attributedString: NSAttributedString {
    let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .black)]
    let brandAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]
    let result = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
    result.append(NSAttributedString(string: brand, attributes: brandAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .center }
  
  var validImageUrls: [String] { [posterImageName] }
}

class CardViewModel {
  
  public var uid: String { cardModel.uid }
  
  func configureBarIndicators(_ indicators: UIStackView!) {
    indicators.isHidden = true
    guard urlsCount > 1 else { return }
    indicators.isHidden = false
    (0..<urlsCount).forEach { (_) in
      let barIndicator = UIView()
      barIndicator.backgroundColor = barDefaultColor
      indicators.addArrangedSubview(barIndicator)
    }
    indicators.arrangedSubviews[0].backgroundColor = .white
  }
  
  private(set) var cardModel: CardModel
  private(set) var imageUrls: [String] = []
  
  private(set) var currentImageIndex: Int {
    get { isHome ? homeCardIndex : detailCardIndex }
    set {
      if isHome { homeCardIndex = newValue }
      else { detailCardIndex = newValue }
    }
  }
  
  private var barDefaultColor = UIColor(white: 0.0, alpha: 0.1)
  
  func enableCurrentBarIndicator(_ indicators: UIStackView!) {
    indicators.arrangedSubviews[currentImageIndex].backgroundColor = .white
  }
  
  func disableCurrentBarIndicator(_ indicators: UIStackView!) {
    indicators.arrangedSubviews[currentImageIndex].backgroundColor = barDefaultColor
  }
  
  private var homeCardIndex = 0
  private var detailCardIndex = 0
  private(set) var isHome = true
  
  var attributedString: NSAttributedString {
    cardModel.attributedString
  }
  
  var textAlignment: NSTextAlignment {
    cardModel.textAlignment
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
  
  @discardableResult
  func nextCard(toRight: Bool) -> Int? {
    guard urlsCount > 0 else { return nil }
    let originalIndex = currentImageIndex
    advanceImageIndex(byStep: toRight ? 1 : -1)
    return originalIndex == currentImageIndex ? nil : currentImageIndex
  }
  
  private func advanceImageIndex(byStep step: Int) {
    if isHome {
      currentImageIndex = ((currentImageIndex + step) % urlsCount + urlsCount) % urlsCount
    } else {
      currentImageIndex = max(0, min(urlsCount - 1, currentImageIndex + step))
    }
  }
  
}
