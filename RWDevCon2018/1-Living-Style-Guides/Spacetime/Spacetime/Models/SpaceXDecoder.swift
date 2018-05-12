//
//  SpaceXDecoder.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

class SpaceXDecoder: JSONDecoder {
  static let shared = SpaceXDecoder()
  
  private override init() {
    super.init()
    self.dateDecodingStrategy = .iso8601
  }
}
