//
// JGProgressHUD+constructor.swift
// Tinder
//
// Created by Gin Imor on 4/20/21.
// Copyright © 2021 Brevity. All rights reserved.
//

import JGProgressHUD

extension JGProgressHUD {
  
  static func new(_ text: String, style: JGProgressHUDStyle = .dark) -> JGProgressHUD {
    let hud = JGProgressHUD(style: style)
    hud.textLabel.text = text
    return hud
  }
}
