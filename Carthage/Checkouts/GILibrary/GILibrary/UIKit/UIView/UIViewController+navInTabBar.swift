//
//  UIViewController+navInTabBar.swift
//  GILibrary
//
//  Created by Gin Imor on 2/14/21.
//
//

import UIKit

public extension UIViewController {
  
  func wrapInNav(tabBarTitle: String, tabBarImage: UIImage) -> UINavigationController {
    let nav = UINavigationController(rootViewController: self)
    nav.tabBarItem.title = tabBarTitle
    nav.tabBarItem.image = tabBarImage
    if #available(iOS 11.0, *) {
      nav.navigationBar.prefersLargeTitles = true
    }
    navigationItem.title = tabBarTitle
    view.backgroundColor = .white
    return nav
  }
}
