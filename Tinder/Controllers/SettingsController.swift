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

protocol SettingsControllerDelegate: class {
  var user: User? {get set}
}

class SettingsController: UITableViewController {
  
  
  class leftShiftedLabel: UILabel {
    override func drawText(in rect: CGRect) {
      super.drawText(in: rect.inset(by: .init(top: 0, left: 8, bottom: 0, right: 0)))
    }
  }
  
  weak var delegate: SettingsControllerDelegate?
  
  lazy var imageButtons: [UIButton] = [
    selectPhotoButton(),
    selectPhotoButton(),
    selectPhotoButton()
  ]
  private var originalImages = [UIImage?](repeating: nil, count: 3)
  weak var lastTappedButton: UIButton?
  var ageRangeCell: AgeRangeCell?
  
  lazy var header: UIView = {
    let header = UIView()
    let innerStackView = UIStackView.verticalStack(arrangedSubviews: [imageButtons[1], imageButtons[2]])
    innerStackView.distribution = .fillEqually
    let outerStackView = UIStackView(arrangedSubviews: [imageButtons[0], innerStackView])
    outerStackView.spacing = 8
    outerStackView.pinToSuperviewEdges(edgeInsets: .init(padding: 8), pinnedView: header)
    imageButtons[0].widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
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
    guard let user = self.user else { return }
    for i in 0..<user.imageUrls.count {
      if let imageUrlString = user.imageUrls[i], let imageUrl = URL(string: imageUrlString) {
        SDWebImageManager.shared.loadImage(with: imageUrl, options: .continueInBackground, progress: nil)
        { (image, _, _, _, _, _) in
          guard let image = image else {
            return
          }
          self.imageButtons[i].setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
          self.originalImages[i] = self.imageButtons[i].image(for: .normal)
        }
      }
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
    case 5:
      header.text = "Seeking Age Range"
    default: ()
    }
    return header
  }

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 { return 300 }
    return 40
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int { 6 }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 { return 0 }
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 5 {
      let cell = AgeRangeCell(style: .default, reuseIdentifier: "ageRangeCell")
      cell.setSeekingAgeForUser(user)
      cell.minAgeDidChange = { [unowned self] minAge in  self.user?.minSeekingAge = minAge }
      cell.maxAgeDidChange = { [unowned self] maxAge in self.user?.maxSeekingAge = maxAge }
      return cell
    }
    
    let cell = SettingsCell(style: .default, reuseIdentifier: "tableViewCell")
    let placeholder: String
    let text: String
    switch indexPath.section {
    case 1:
      placeholder = "Enter Name"
      text = user?.name ?? ""
      cell.textField.addTarget(self, action: #selector(didEditedName), for: .editingChanged)
    case 2:
      placeholder = "Enter Profession"
      text = user?.profession ?? ""
      cell.textField.addTarget(self, action: #selector(didEditedProfession), for: .editingChanged)
    case 3:
      placeholder = "Enter Age"
      if let age = user?.age {
        text = "\(age)"
      } else { text = "" }
      cell.textField.addTarget(self, action: #selector(didEditedAge), for: .editingChanged)
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
  
  @objc func didEditedName(_ textField: UITextField) {
    user?.name = textField.text ?? ""
  }
  
  @objc func didEditedProfession(_ textField: UITextField) {
    user?.profession = textField.text ?? ""
  }
  
  @objc func didEditedAge(_ textField: UITextField) {
    user?.age = Int(textField.text ?? "")
  }
  
  func selectPhotoButton() -> UIButton {
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
    guard let user = self.user else { return }
    let hud = JGProgressHUD(style: .dark)
    hud.textLabel.text = "Uploading"
    hud.show(in: view)
    let imageUrls = user.imageUrls
    var imageData = [Data?](repeating: nil, count: 3)
    for i in 0..<imageUrls.count {
      if let buttonImage = imageButtons[i].image(for: .normal) {
        if let originalImage = originalImages[i], buttonImage.isEqual(originalImage) {
          continue
        }
        imageData[i] = buttonImage.jpegData(compressionQuality: 0.8)
        print("image button \(i)'s image change")
      }
    }
    TinderFirebaseService.storeImages(imagesDataProvider: { imageData }, for: user,
      initialImageUrls: imageUrls) {newUser, error in
      hud.dismiss()
      guard error == nil else {
        print("error occur when store images: \(String(describing: error))")
        return
      }
      self.delegate?.user = newUser
      self.dismiss(animated: true)
    }
  }
  
  @objc func handleSelectPhoto(_ button: UIButton) {
    lastTappedButton = button
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
    [UIImagePickerController.InfoKey : Any]) {
    let image = info[.originalImage] as? UIImage
    lastTappedButton?.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    dismiss(animated: true)
  }
}
