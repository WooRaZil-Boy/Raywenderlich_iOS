//
//  APIEndpoint.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

protocol APIEndpoint {
  
  init?(rawValue: String)
  var rawValue: String { get }
  
  static var baseURLString: String { get }
}

extension APIEndpoint {
  
  static func urlFromStringPieces(_ strings: [String]) -> URL {
    let urlString = strings.joined(separator: "/")
    
    guard let url = URL(string: urlString) else {
      fatalError("Could not create a URL from \(urlString)")
    }
    
    return url
  }
}

extension URL {
  
  func appendingParameters(_ parameters: [URLQueryItem]) -> URL {
    guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
      assertionFailure("Couldn't break URL into components")
      return self
    }
    
    if var queryItems = components.queryItems {
      queryItems.append(contentsOf: parameters)
      components.queryItems = queryItems
    } else {
      components.queryItems = parameters
    }
    
    guard let url = components.url else {
      assertionFailure("Couldn't make components from URL")
      return self
    }
    
    return url
  }
}
