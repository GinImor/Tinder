//
// ChatLogCell.swift
// Tinder
//
// Created by Gin Imor on 4/21/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class ChatLogCell: GIGridSelfSizingCell<Message> {
  
  private let bubbleView = UIView()
  private let chatTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.textContainerInset = .init(8)
    textView.isScrollEnabled = false
    textView.isEditable = false
    textView.backgroundColor = .clear
    return textView
  }()
  
  private var bubbleHorizontalConstraints: [NSLayoutConstraint] = []
  
  override func setup() {
    super.setup()
    // chatTextView determine the size of bubbleView
    chatTextView.add(to: bubbleView).filling()
    bubbleView.add(to: contentView).roundedCorner(8)
      .vLining() {
        // losen bubbleView's bottomAnchor to contentView's bottomAnchor constraint
        // strech contentView's height, but not strictly
        $0[1].priority = UILayoutPriority(750) }
      .hLining(edgeInsets: .init(16)) {
        // bubbleView's width not equal to contentView's width which is determined by
        // its width constraint whose constant is assigned in cellForItem
        // bubbleView's width is less than or equal to 300
        // so in conclusion, cell's width is determined by contentView's width constraint
        // cell's height is determined by chatTextView's height, at first, chatTextView's width
        // grow, once it reach the 300 threshold, the height grow, so the bubbleView's height grow,
        // contentView and cell's height grow
        $0[1].isActive = false
        self.bubbleHorizontalConstraints = $0 }
      .widthAnchor.constraint(lessThanOrEqualToConstant: 300).isActive = true
  }
  
  override func didSetItem() {
    chatTextView.text = item.text
    // if from current user, disable leading constraint and enable trailing constraint
    // if not from current user, do the opposite
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

