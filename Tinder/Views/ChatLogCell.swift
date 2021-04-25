//
// ChatLogCell.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class ChatLogCell: CollectionSelfSizingCell<Message> {
  
  private let bubbleView = UIView()
  private let chatTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.textContainerInset = UIEdgeInsets(top: 8, leftRight: 8, bottom: 8)
    textView.isScrollEnabled = false
    textView.isEditable = false
    textView.backgroundColor = .clear
    return textView
  }()
  
  private var bubbleHorizontalConstraints: [NSLayoutConstraint] = []
  
  override func setup() {
    super.setup()
    chatTextView.add(to: bubbleView).filling()
    bubbleView.add(to: contentView).roundedCorner(8)
      .vLining(.vertical) { $0[1].withPriority(value: 750) }
      .hLining(.horizontal, value: 16) {
        $0[1].isActive = false
        self.bubbleHorizontalConstraints = $0
      }
      .widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
  }
  
  override func didSetItem() {
    chatTextView.text = item.text
    if item.isFromCurrentUser {
      bubbleHorizontalConstraints[0].isActive = false
      bubbleHorizontalConstraints[1].isActive = true
      bubbleView.backgroundColor = UIColor(rgb: (2, 122, 255))
      chatTextView.textColor = .white
    } else {
      bubbleHorizontalConstraints[1].isActive = false
      bubbleHorizontalConstraints[0].isActive = true
      bubbleView.backgroundColor = UIColor(rgb: (233, 233, 235))
      chatTextView.textColor = .black
    }
  }
}

