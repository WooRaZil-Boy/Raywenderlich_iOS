//
//  NASADecoder.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

class NASADecoder: JSONDecoder {
  
  static let shared = NASADecoder()
  
  private override init() {
    super.init()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    self.dateDecodingStrategy = .formatted(formatter)
  }
}

class NASAEncoder: JSONEncoder {
  
  static let shared = NASAEncoder()
  
  private override init() {
    super.init()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    self.dateEncodingStrategy = .formatted(formatter)
  }
}
