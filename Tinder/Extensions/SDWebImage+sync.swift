//
// SDWebImage+sync.swift
// Tinder
//
// Created by Gin Imor on 4/16/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIImageView {
  
  func sd_setImageSync(with url: String, dispatchGroup: DispatchGroup) {
    dispatchGroup.enter()
    sd_setImage(with: URL(string: url)) { _, _, _, _ in
      do { dispatchGroup.leave() }
    }
  }
}
