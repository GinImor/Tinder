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
import GILibrary

protocol SettingsControllerDelegate: AnyObject {
  func didSaveNewUser(_ newUser: User)
  func didLogOut()
}

class SettingsController: UITableViewController {
  
  class leftShiftedLabel: UILabel {
    override func drawText(in rect: CGRect) {
      super.drawText(in: rect.inset(by: .init(top: 0, left: 8, bottom: 0, right: 0)))
    }
  }
  
  var user: User?
  
  weak var delegate: SettingsControllerDelegate?
  
  private let hud = JGProgressHUD.new("")
  
  private var originalImages = [UIImage?](repeating: nil, count: 3)
  private weak var lastTappedButton: UIButton?
  private var ageRangeCell: AgeRangeCell?
  
  private lazy var imageButtons = (0..<3).map { _ -> LoadingButton in selectPhotoButton() }
  
  private lazy var header: UIView = {
    let header = UIView()
    hStack(
      imageButtons[0],
      vStack(imageButtons[1], imageButtons[2])
        .distributing(.fillEqually)
    )
    .add(to: header).filling(header, edgeInsets: .init(8))
    imageButtons[0].sizing(.width, to: header, multiplier: 0.45)
    return header
  }()
  
  private lazy var footer: UIView = {
    let footer = UIView()
    let logoutButton = LogoutFooterButton()
    logoutButton.addTarget(self, action: #selector(handleLogout))
    logoutButton.add(to: footer).sizing(.width, multiplier: 0.8).centering(footer)
    footer.layoutIfNeeded()
    footer.frame.size.height += 32 + logoutButton.frame.height
    return footer
  }()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTableView()
    fetchCurrentUserInfo()
  }
  
  private func setupNavigationBar() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Settings"
    navigationItem.leftBarButtonItem =
      UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
  }
  
  private func setupTableView() {
    tableView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    tableView.tableFooterView = footer
    tableView.keyboardDismissMode = .interactive
    tableView.contentInset.bottom = 16
    tableView.showsVerticalScrollIndicator = false
    tableView.allowsSelection = false
  }
  
  private func fetchCurrentUserInfo() {
    db.fetchCurrentUserIfNecessary {
      self.hud.show(in: self.navigationController?.view ?? self.view)
    } completion: {
      [weak self] user, error in
      self?.hud.dismiss()
      if let error = error {
        print("fetch current user error", error)
        // if can't get a user, dismiss back to home
        self?.dismiss(animated: true)
        return
      }
      self?.user = user
      self?.tableView.reloadData()
      self?.loadImages()
    }
  }
  
  private func loadImages() {
    guard let user = self.user else { return }
    for i in 0..<user.info.imageUrls.count {
      if let imageUrlString = user.info.imageUrls[i], let imageUrl = URL(string: imageUrlString) {
        imageButtons[i].showLoading()
        SDWebImageManager.shared.loadImage(with: imageUrl, options: .continueInBackground, progress: nil)
        { [weak self] (image, data, _, _, _, _) in
          defer { self?.imageButtons[i].hideLoading() }
          // it doesn't matter that error occurs, user has the correct image url, guard can be deleted if
          // necessary, it only effect comparison, if they turn out to be the same image
          guard let image = image?.withRenderingMode(.alwaysOriginal) else { return }
          self?.imageButtons[i].setImage(image, for: .normal)
          self?.originalImages[i] = image
        }
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 { return header }
    let header = leftShiftedLabel()
    header.backgroundColor = tableView.backgroundColor
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
    section == 0 ? 300 : 40
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int { 6 }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    section == 0 ? 0 : 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 5 {
      let cell = AgeRangeCell(style: .default, reuseIdentifier: "ageRangeCell")
      cell.setSeekingAgeForUser(user)
      cell.minAgeDidChange = { [unowned self] minAge in
        self.user?.preference.minSeekingAge = minAge }
      cell.maxAgeDidChange = { [unowned self] maxAge in
        self.user?.preference.maxSeekingAge = maxAge }
      return cell
    }
    
    let cell = SettingsCell(style: .default, reuseIdentifier: "tableViewCell")
    switch indexPath.section {
    case 1:
      cell.textField.placeholder = "Enter Name"
      cell.textField.text = user?.info.name ?? ""
      cell.textField.addTarget(self, action: #selector(didEditedName), for: .editingChanged)
    case 2:
      cell.textField.placeholder = "Enter Profession"
      cell.textField.text = user?.info.profession ?? ""
      cell.textField.addTarget(self, action: #selector(didEditedProfession), for: .editingChanged)
    case 3:
      cell.textField.placeholder = "Enter Age"
      if let age = user?.info.age { cell.textField.text = String(age) }
      cell.textField.addTarget(self, action: #selector(didEditedAge), for: .editingChanged)
    case 4:
      cell.textField.placeholder = "Enter Bio"
      cell.textField.text = user?.info.bio
      cell.textField.addTarget(self, action: #selector(didEditedBio), for: .editingChanged)
    default: ()
    }
    return cell
  }
  
  @objc private func didEditedName(_ textField: UITextField) {
    user?.info.name = textField.text ?? ""
  }
  
  @objc private func didEditedProfession(_ textField: UITextField) {
    user?.info.profession = textField.text
  }
  
  @objc private func didEditedAge(_ textField: UITextField) {
    user?.info.age = Int(textField.text ?? "")
  }
  
  @objc private func didEditedBio(_ textField: UITextField) {
    user?.info.bio = textField.text
  }
  
  private func selectPhotoButton() -> LoadingButton {
    let button = LoadingButton(type: .system)
    button.backgroundColor = .white
    button.setTitle("Select Photo", for: .normal)
    button.layer.cornerRadius = 8
    button.imageView?.contentMode = .scaleAspectFill
    button.clipsToBounds = true
    button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
    return button
  }
  
  @objc private func handleCancel() {
    dismiss(animated: true)
  }
  
  @objc private func handleLogout() {
    let actionSheet = UIAlertController(title: "", message: "Are You Sure to Log Out The Account?", preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { [unowned self] (_) in
      auth.logout()
      self.dismiss(animated: true)
      self.delegate?.didLogOut()
    }))
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    present(actionSheet, animated: true)
  }
  
  @objc private func handleSave() {
    guard var user = self.user else { return }
    let hud = JGProgressHUD.new("Uploading")
    hud.show(in: navigationController?.view ?? view)
    // record which image should be uploaded
    var imageDataArray = [Data?](repeating: nil, count: 3)
    for i in 0..<3 {
      // if button doesn't have image, means doesn't change
      if let buttonImage = self.imageButtons[i].image(for: .normal) {
        if let originalImage = self.originalImages[i], originalImage.isEqual(buttonImage) {
          continue
        }
        imageDataArray[i] = buttonImage.scaledJpegDataForUpload
      }
    }
    // upload new images to storage, delete old images,
    // update user with the returned imageUrls to firestore
    sto.uploadImages(imageDataArray, for: user) { (imageUrls) in
      user.info.imageUrls = imageUrls
      db.updateUser(user) { [weak self] (error) in
        hud.dismiss()
        self?.delegate?.didSaveNewUser(user)
        self?.dismiss(animated: true)
      }
    }
  }
  
  @objc private func handleSelectPhoto(_ button: UIButton) {
    lastTappedButton = button
    let imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    present(imagePicker, animated: true)
  }
}

extension SettingsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info:
    [UIImagePickerController.InfoKey : Any]) {
    let image = (info[.originalImage] as? UIImage)?.withRenderingMode(.alwaysOriginal)
    lastTappedButton?.setImage(image, for: .normal)
    dismiss(animated: true)
  }
}
