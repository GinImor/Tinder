//
//  SettingsCell.swift
//  Tinder
//
//  Created by Gin Imor on 3/25/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class SettingsCell: UITableViewCell {
  
  var textField = PaddingCellTextField()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    textField.add(to: self).filling(self)
  }
}
