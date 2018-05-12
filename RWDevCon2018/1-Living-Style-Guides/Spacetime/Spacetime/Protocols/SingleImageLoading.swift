//
//  ImageLoading.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/25/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

protocol SingleImageLoading: class {
  
  var targetImageView: UIImageView! { get }
  var loadingView: UIActivityIndicatorView! { get }
  var imageLoadTask: URLSessionTask? { get set }
}

extension SingleImageLoading {
  
  func loadImage(for urlString: String) {
    self.loadingView.startAnimating()
    self.imageLoadTask = ImageLoader.loadImage(from: urlString,
                                               errorCompletion: {
                                                [weak self]
                                                _ in
                                                self?.targetImageView.tintColor = UIColor.spc_from(r: 135, g: 20, b: 12)
                                                self?.imageLoadCompleted(image: nil)
                                               },
                                               successCompletion: {
                                                [weak self]
                                                image in
                                                self?.imageLoadCompleted(image: image)
                                               })
  }
  
  private var placeholderImage: UIImage {
    return #imageLiteral(resourceName: "material_ic_image").withRenderingMode(.alwaysTemplate)
  }
  
  private func imageLoadCompleted(image: UIImage?) {
    self.imageLoadTask = nil
    self.loadingView.stopAnimating()
    
    guard let loadedImage = image else {
      self.targetImageView.image = self.placeholderImage
      return 
    }
    self.targetImageView.image = loadedImage
  }
  
}
