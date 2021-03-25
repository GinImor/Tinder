//
//  SettingsController.swift
//  Tinder
//
//  Created by Gin Imor on 3/25/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit
import JGProgressHUD
import SDWebImage

class SettingsController: UITableViewController {
  
  class leftShiftedLabel: UILabel {
    override func drawText(in rect: CGRect) {
      super.drawText(in: rect.inset(by: .init(top: 0, left: 8, bottom: 0, right: 0)))
    }
  }
  
  lazy var imageButton1 = selecPhotoButton()
  lazy var imageButton2 = selecPhotoButton()
  lazy var imageButton3 = selecPhotoButton()
  weak var lastTappedButton: UIButton?
  
  lazy var header: UIView = {
    let header = UIView()
    let innerStackView = UIStackView.verticalStack(arrangedSubviews: [imageButton2, imageButton3])
    innerStackView.distribution = .fillEqually
    let outterStackView = UIStackView(arrangedSubviews: [imageButton1, innerStackView])
    outterStackView.spacing = 8
    outterStackView.pinToSuperviewEdges(edgeInsets: .init(padding: 8), pinnedView: header)
    imageButton1.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
    return header
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTableView()
    fetchData()
  }
  
  var user: User?
  
  private func fetchData() {
    TinderFirebaseService.fetchCurrentUser { user, error in
      if let error = error {
        print("fetch current user error", error)
        return
      }
      self.user = user
      self.tableView.reloadData()
      self.loadImages()
    }
  }
  
  private func loadImages() {
    guard let imageUrlString = user?.imageUrl1, let imageUrl = URL(string: imageUrlString) else { return }
    SDWebImageManager.shared.loadImage(with: imageUrl, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
      guard let image = image else { return }
      self.imageButton1.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
    }
  }
  
  private func setupNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Settings"
    navigationItem.leftBarButtonItem =
      UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    navigationItem.rightBarButtonItems = [
      UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
      UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    ]
  }
  
  private func setupTableView() {
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    tableView.tableFooterView = UIView()
    tableView.keyboardDismissMode = .interactive
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 { return header }
    let header = leftShiftedLabel()
    switch section {
    case 1:
      header.text = "Name"
    case 2:
      header.text = "Profession"
    case 3:
      header.text = "Age"
    case 4:
      header.text = "Bio"
    default: ()
    }
    return header
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 { return 300 }
    return 40
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int { 5 }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 { return 0 }
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = SettingsCell(style: .default, reuseIdentifier: "tableViewCell")
    let placeholder: String
    let text: String
    switch indexPath.section {
    case 1:
      placeholder = "Enter Name"
      text = user?.name ?? ""
    case 2:
      placeholder = "Enter Profession"
      text = user?.profession ?? ""
    case 3:
      placeholder = "Enter Age"
      if let age = user?.age {
        text = "\(age)"
      } else { text = "" }
    case 4:
      placeholder = "Enter Bio"
      text = ""
    default:
      placeholder = ""
      text = ""
    }
    cell.textField.placeholder = placeholder
    cell.textField.text = text
    return cell
  }
  
  func selecPhotoButton() -> UIButton {
    let button = UIButton(type: .system)
    button.backgroundColor = .white
    button.setTitle("Select Photo", for: .normal)
    button.layer.cornerRadius = 8
    button.imageView?.contentMode = .scaleAspectFill
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
    return button
  }
  
  @objc func handleCancel() {
    dismiss(animated: true)
  }
  
  @objc func handleLogout() {
    
  }
  
  @objc func handleSave() {
    
  }
  
  @objc func handleSelectPhoto(_ button: UIButton) {
    lastTappedButton = button
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let image = info[.originalImage] as? UIImage
    lastTappedButton?.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    dismiss(animated: true)
  }
}
