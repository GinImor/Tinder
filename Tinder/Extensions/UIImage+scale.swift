//
//  UIImage+scale.swift
//  Tinder
//
//  Created by Gin Imor on 11/3/21.
//  Copyright © 2021 Brevity. All rights reserved.
//

import UIKit

extension UIImage {
  
  var scaledJpegDataForUpload: Data? {
    scaledForUpload?.jpegData(compressionQuality: 0.4)
  }
  
  var scaledForUpload: UIImage? {
    let maxImageSideLength: CGFloat = 480
    let largerSide: CGFloat = max(size.width, size.height)
    // if the max of width and height still <= maxImageSideLength, then can use them as is,
    // if the max > maxImageSideLength, scale down the width and height <= maxImageSideLength
    let scaleRatio: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
    let newImageSize = CGSize(width: size.width / scaleRatio, height: size.height / scaleRatio)
    return image(scaledTo: newImageSize)
  }

  func image(scaledTo size: CGSize) -> UIImage? {
    defer { UIGraphicsEndImageContext() }
    UIGraphicsBeginImageContextWithOptions(size, true, 0)
    draw(in: CGRect(origin: .zero, size: size))
    return UIGraphicsGetImageFromCurrentImageContext()
  }
  
}
