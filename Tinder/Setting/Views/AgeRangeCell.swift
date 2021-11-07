//
// AgeRangeCell.swift
// Tinder
//
// Created by Gin Imor on 4/9/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class AgeRangeCell: UITableViewCell {
  
  private class func ageRangeSlider() -> UISlider {
    let slider = UISlider()
    slider.minimumValue = 18
    slider.maximumValue = 100
    return slider
  }
  
  private let minSlider: UISlider = ageRangeSlider()
  private let maxSlider: UISlider = ageRangeSlider()
  
  private let minLabel = UILabel.new("Min: 0", attributes: nil)
  private let maxLabel = UILabel.new("Max: 0", attributes: nil)
  
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
    vStack(
      hStack(minLabel.sizing(width: 80), minSlider).spacing(16),
      hStack(maxLabel.sizing(width: 80), maxSlider).spacing(16)
    )
    .add(to: self).filling(edgeInsets: .init(16))

    minSlider.addTarget(self, action: #selector(handleMinAgeChange))
    maxSlider.addTarget(self, action: #selector(handleMaxAgeChange))
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
