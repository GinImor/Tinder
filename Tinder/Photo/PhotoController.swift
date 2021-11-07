//
// PhotoController.swift
// Tinder
//
// Created by Gin Imor on 4/14/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import GILibrary

class PhotoController: UIViewController {
  
  var page = 0
  
  // for reuse, just assign a new imageUrlString, and it will load
  // the new image
  var imageUrlString: String? {
    didSet {
      guard let imageUrlString = imageUrlString,
            let imageUrl = URL(string: imageUrlString)
      else { return }
      imageView.sd_setImage(with: imageUrl)
    }
  }
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    imageView.add(to: view).filling(view)
  }
  
}

