//
// TextViewInputAccessoryView.swift
// Tinder
//
// Created by Gin Imor on 4/22/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class TextViewInputAccessoryView: UIView, UITextViewDelegate {
  
  var didTappedSend: ((UIButton) -> Void)?
  
  private let placeholderLabel = UILabel.new("Enter Message", .body, .lightGray, .left)
  private let sendButton = UIButton.system(text: "Send", tintColor: .black)
  
  var text: String? {
    get { inputTextView.text }
    set { inputTextView.text = newValue }
  }
  
  private lazy var _inputTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.isScrollEnabled = false
    textView.isHidden = true
    return textView
  }()
  
  private lazy var inputTextView: UITextView = {
    let textView = UITextView()
    textView.delegate = self
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.layer.cornerRadius = 8
    textView.layer.masksToBounds = true
    return textView
  }()
  
  override var intrinsicContentSize: CGSize { .zero }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  

  private func setup() {
    backgroundColor = .systemGray5
    // grow with text view
    autoresizingMask = .flexibleHeight
    shadow(opacity: 0.1, radius: 8, offset: CGSize(width: 0, height: -8), color: .lightGray)
    sendButton.titleLabel?.font = .systemFont(ofSize: 16)
    sendButton.addTarget(self, action: #selector(handleSend))
    
    let container = UIView()
    inputTextView.add(to: container).filling(container)
    _inputTextView.add(to: container).hLining(to: container)
    
    inputTextView.sizing(.height, to: _inputTextView) { $0.priority = .defaultHigh }
    inputTextView.heightAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true
    
    hStack(container, sendButton.withCH(999, CR: 999, axis: .horizontal) )
      .aligning(.lastBaseline).padding(edgeInsets: .init(8, 16, 8)).add(to: self).filling(self)
    
    placeholderLabel.add(to: inputTextView).hLining(edgeInsets: .init(4)).vLining(.centerY)
  }
  
  @objc private func handleSend() {
    didTappedSend?(sendButton)
  }
  
  func showPlaceholder() {
    _inputTextView.text = ""
    placeholderLabel.isHidden = false
  }
  
  // UITextViewDelegate
  func textViewDidChange(_ textView: UITextView) {
    _inputTextView.text = textView.text
    placeholderLabel.isHidden = textView.text != ""
  }
  
  
}
