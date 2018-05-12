//
//  LocalImageCache.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

/// Stores images locally so we're not fetching them from the interwebs a million times
/// if we don't have to.
struct LocalImageCache {
  
  private static func urlInCachesDirectory(for imageURL: URL) -> URL {
    let imageName = imageURL.path.replacingOccurrences(of: "/", with: "-")
    guard let cacheDirectory = FileManager
                                  .default
                                  .urls(for: .cachesDirectory, in: .userDomainMask)
                                  .first else {
      fatalError("Could not access caches directory")
    }
    
    return cacheDirectory.appendingPathComponent(imageName)

  }
  
  /// Attemtps to retrieve an image from the cache for a given URL.
  ///
  /// - Parameter url: The URL to try and retreive the image for.
  /// - Returns: The image, or nil if one does not exist.
  static func image(for url: URL) -> UIImage? {
    let imageURL = self.urlInCachesDirectory(for: url)
    guard let imageData = try? Data(contentsOf: imageURL) else {
      return nil
    }
    
    return UIImage(data: imageData)
  }
  
  /// Attempts to write an image to the cache for a given URL.
  ///
  /// - Parameters:
  ///   - image: The image to store
  ///   - url: The URL to store the image for.
  static func cacheImage(_ image: UIImage, for url: URL) {
    let imageURL = self.urlInCachesDirectory(for: url)
    
    guard let imageData = UIImagePNGRepresentation(image) else {
      assertionFailure("Could not get Data for image!")
      return
    }
    
    do {
      try imageData.write(to: imageURL)
    } catch let error {
      NSLog("Error writing data for \(url) to \(imageURL): \(error)")
    }
  }
}
