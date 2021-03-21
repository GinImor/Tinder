//
//  ViewController.swift
//  Tinder
//
//  Created by Gin Imor on 3/21/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    setupViews()
  }

  private func setupViews() {
    view.backgroundColor = .systemBackground
    let containerView = UINib(nibName: "HomeView", bundle: .main).instantiate(withOwner: nil, options: nil).first as! UIView
    containerView.frame = view.bounds
    view.addSubview(containerView)
  }
}

