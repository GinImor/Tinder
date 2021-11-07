//
//  StorageManager.swift
//  Tinder
//
//  Created by Gin Imor on 10/15/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import FirebaseStorage

let sto = StorageManager()

enum StorageError: Error {
  case noResponse
}

class StorageManager {

  var storage: Storage { Storage.storage() }
  var storageRef: StorageReference { Storage.storage().reference() }
  
  enum StorageChild: String {
    case profileImages = "profile_images"
  }
  
  // put the content data to current user's storage child path with a random file name
  // and return the download url to the completion block
  func putData(
    _ contentData: Data,
    to child: StorageChild,
    completion: @escaping (String?, Error?) -> Void)
  {
    guard let uid = auth.uid else {
      completion(nil, AuthError.notSignedIn)
      return
    }
    let ref = storageRef.child("\(uid)/\(child.rawValue)/\(randomFileName())")
    ref.putData(contentData, metadata: nil) { (_, error) in
      guard error == nil else {
        completion(nil, error)
        return
      }
      ref.downloadURL(completion: { (url, error) in
        guard error == nil else {
          completion(nil, error)
          return
        }
        guard let imageUrl = url?.absoluteString else {
          completion(nil, StorageError.noResponse)
          return
        }
        completion(imageUrl, nil)
      })
    }
  }
  
  func uploadImages(
    _ imageDataArray: [Data?],
    for user: User,
    completion: @escaping ([String?]) -> Void
  ) {
    let dispatchGroup = DispatchGroup()
    var imageUrls = user.imageUrls
    for i in 0..<imageDataArray.count {
      // if there is imageData, means need to update
      guard let imageData = imageDataArray[i] else { continue }
      var deleteImageError: Error?
      let deleteImageDispatchGroup = DispatchGroup()
      dispatchGroup.enter()
      // has image before, need to delete it
      if let imageUrl = imageUrls[i] {
        deleteImageDispatchGroup.enter()
        storage.reference(forURL: imageUrl).delete { (error) in
          defer { deleteImageDispatchGroup.leave() }
          deleteImageError = error
        }
      }
      // come down to one case: no image left in storage, upload the new image
      // to storage if no delete error before
      deleteImageDispatchGroup.notify(queue: .main) { [weak self] in
        if let error = deleteImageError {
          print("delete image error: ", error)
          dispatchGroup.leave()
          return
        }
        self?.putData(imageData, to: .profileImages) { imageUrl, error in
          defer { dispatchGroup.leave() }
          // assign imageUrl whether it is nil or not, cause there is no
          // rolling back after the successful deletion
          imageUrls[i] = imageUrl
        }
      }
    }
    dispatchGroup.notify(queue: .main) { completion(imageUrls) }
  }
  
  private func randomFileName() -> String {
    let uuid = UUID().uuidString
    let randomNumber = Int.random(in: 1...1000)
    let timeInterval = Date().timeIntervalSince1970
    return "\(uuid)_\(randomNumber)_\(timeInterval).jpg"
  }
}
