//
// TextViewInputAccessoryView.swift
// Tinder
//
// Created by Gin Imor on 4/22/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class TextViewInputAccessoryView: UIView, UITextViewDelegate {
  
  var didTappedSend: ((UIButton) -> Void)?
  
  let placeholderLabel = UILabel.new("Enter Message", textStyle: .body, textColor: .lightGray)
  let sendButton = UIButton.system(text: "send", tintColor: .black)
  
  public var text: String? {
    get { inputTextView.text }
    set { inputTextView.text = newValue }
  }
  
  func textViewDidChange(_ textView: UITextView) {
    placeholderLabel.isHidden = textView.text != ""
  }
  
  lazy var inputTextView: UITextView = {
    let textView = UITextView()
    textView.delegate = self
    textView.font = UIFont.preferredFont(forTextStyle: .body)
    textView.isScrollEnabled = false
    return textView
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    backgroundColor = .white
    autoresizingMask = .flexibleHeight
    shadow(opacity: 0.1, radius: 8, offset: CGSize(width: 0, height: -8), color: .lightGray)
    sendButton.addTarget(self, action: #selector(handleSend))
    HStack(
      inputTextView,
      sendButton.withHugging(1000, compressionResistance: 1000, axis: .horizontal)
    )
      .aliment(.center).spacing()
      .view.add(to: self).filling(self)
      .padding(edgeInsets: .init(top: 0, leftRight: 16, bottom: 0))
    placeholderLabel.add(to: inputTextView).hLining(.horizontal, value: 4).vLining(.centerY)
  }
  
  @objc func handleSend() {
    didTappedSend?(sendButton)
  }
  
  override var intrinsicContentSize: CGSize { .zero }
  
  func showPlaceholder() {
    placeholderLabel.isHidden = false
  }
}
