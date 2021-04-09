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
    let professionAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
    let ageString = age == nil ? "" : "  \(age!)\n"
    let professionString = "\(profession ?? "")"
    let result = NSMutableAttributedString(string: name, attributes: nameAttributes)
    result.append(NSAttributedString(string: ageString, attributes: ageAttributes))
    result.append(NSAttributedString(string: professionString, attributes: professionAttributes))
    return result
  }
  
  var textAlignment: NSTextAlignment { .left }
  
  var imageNames: [String] { imageUrls.compactMap { $0 } }
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
