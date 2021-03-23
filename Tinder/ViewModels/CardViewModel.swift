//
//  CardViewModel.swift
//  Tinder
//
//  Created by Gin Imor on 3/22/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

protocol CardModel {
  var attributedString: NSAttributedString { get }
  var textAlignment: NSTextAlignment { get }
  var imageNames: [String] { get }
}

extension User: CardModel {
  
  var attributedString: NSAttributedString {
    let nameAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .largeTitle)]
    let ageAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
    let prefessionAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
    let result = NSMutableAttributedString(string: name, attributes: nameAttributes)
    result.append(NSAttributedString(string: " \(age)\n", attributes: ageAttributes))
    result.append(NSAttributedString(string: profession, attributes: prefessionAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .left }
}

extension Advertiser: CardModel {
  
  var attributedString: NSAttributedString {
    let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 28, weight: .black)]
    let brandAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .heavy)]
    let result = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
    result.append(NSAttributedString(string: brand, attributes: brandAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .center }
  
  var imageNames: [String] { [posterImageName] }
}

class CardViewModel {
  
  var cardModel: CardModel?
  
  func setModel(_ cardModel: CardModel) {
    self.cardModel = cardModel
  }
  
  func configure(_ cardView: CardView) {
    guard let cardModel = self.cardModel else { return }
    cardView.informationLabel.attributedText = cardModel.attributedString
    cardView.informationLabel.textAlignment = cardModel.textAlignment
    cardView.setImageNames(cardModel.imageNames)
  }
  
}
