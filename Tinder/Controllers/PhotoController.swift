//
// PhotoController.swift
// Tinder
//
// Created by Gin Imor on 4/14/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class PhotoController: UIViewController {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.disableTAMIC()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()
  
  init(imageUrl: String) {
    if let url = URL(string: imageUrl) {
      imageView.sd_setImage(with: url)
    }
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    imageView.pinToSuperviewEdges(pinnedView: view)
  }
}

