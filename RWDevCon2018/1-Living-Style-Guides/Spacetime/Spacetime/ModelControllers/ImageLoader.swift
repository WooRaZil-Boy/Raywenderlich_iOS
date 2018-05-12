//
//  ImageLoader.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import UIKit

enum ImageLoaderError: Error {
  case
  couldNotCreateURL,
  couldNotCreateSecureURL,
  couldNotCreateImageFromData
}

struct ImageLoader {
  
  /// Attempts to load an image for a given URL string
  /// Will try to load from the image cache before hitting the network
  ///
  /// - Parameters:
  ///   - urlString: The string of a URL to attempt to load an image from
  ///   - errorCompletion: The completion closure to execute on any error
  ///   - successCompletion: The completion closure to execute when the image is ready to display.
  /// - Returns: [Optional] The URLSessionTask if one was initiated, or nil if the operation completed
  ///                       synchronously (for example, when an image was loaded from the cache).
  static func loadImage(from urlString: String,
                        errorCompletion: @escaping (Error) -> Void,
                        successCompletion: @escaping (UIImage) -> Void) -> URLSessionTask? {
    guard let url = URL(string: urlString) else {
      errorCompletion(ImageLoaderError.couldNotCreateURL)
      return nil
    }
    
    if let cachedImage = LocalImageCache.image(for: url) {
      successCompletion(cachedImage)
      return nil
    }
        
    return NetworkDataFetcher.fetchData(from: url,
                                        errorCompletion: errorCompletion,
                                        successCompletion: {
                                          data in
                                          
                                          guard let image = UIImage(data: data) else {
                                            errorCompletion(ImageLoaderError.couldNotCreateImageFromData)
                                            return
                                          }
                                          
                                          LocalImageCache.cacheImage(image, for: url)
                                          successCompletion(image)
                                        })
  }
}
