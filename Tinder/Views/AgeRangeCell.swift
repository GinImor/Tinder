//
// AgeRangeCell.swift
// Tinder
//
// Created by Gin Imor on 4/9/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class AgeRangeCell: UITableViewCell {
  
  private class func ageRangeSlider() -> UISlider {
    let slider = UISlider()
    slider.minimumValue = 18
    slider.maximumValue = 100
    return slider
  }
  
  private let minSlider: UISlider = ageRangeSlider()
  private let maxSlider: UISlider = ageRangeSlider()
  
  private let minLabel: UILabel = {
    let label = UILabel()
    label.text = "Min: 0"
    return label
  }()
  
  private let maxLabel: UILabel = {
    let label = UILabel()
    label.text = "Max: 0"
    return label
  }()
  
  var minAgeDidChange: ((Int) -> Void)?
  var maxAgeDidChange: ((Int) -> Void)?
  
  override init(style: CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    let minStackView = UIStackView(arrangedSubviews: [minLabel, minSlider])
    let maxStackView = UIStackView(arrangedSubviews: [maxLabel, maxSlider])
    minStackView.spacing = 16
    maxStackView.spacing = 16
    minLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
    maxLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
    _ = UIStackView.verticalStack(
      arrangedSubviews: [minStackView, maxStackView],
      pinToSuperview: self,
      edgeInsets: .init(padding: 16))
    
    minSlider.addTarget(self, action: #selector(handleMinAgeChange), for: .valueChanged)
    maxSlider.addTarget(self, action: #selector(handleMaxAgeChange), for: .valueChanged)
  }
  
  @objc func handleMinAgeChange() {
    let minValue = Int(minSlider.value)
    if minSlider.value > maxSlider.value {
      maxSlider.value = minSlider.value
      maxLabel.text = "Max: \(minValue)"
      maxAgeDidChange?(minValue)
    }
    minLabel.text = "Min: \(minValue)"
    minAgeDidChange?(minValue)
  }
  
  @objc func handleMaxAgeChange() {
    if minSlider.value > maxSlider.value {
      maxSlider.value = minSlider.value
    }
    let maxValue = Int(maxSlider.value)
    maxLabel.text = "Max: \(maxValue)"
    maxAgeDidChange?(maxValue)
  }
  
  func setSeekingAgeForUser(_ user: User?) {
    guard let user = user else { return }
    minSlider.value = Float(user.minSeekingAge)
    maxSlider.value = Float(user.maxSeekingAge)
    minLabel.text = "Min: \(user.minSeekingAge)"
    maxLabel.text = "Max: \(user.maxSeekingAge)"
  }
  
}
