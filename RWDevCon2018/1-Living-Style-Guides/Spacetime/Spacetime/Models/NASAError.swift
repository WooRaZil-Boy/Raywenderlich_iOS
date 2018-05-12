//
//  NASAError.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 3/18/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation

struct ErrorWrapper: Codable {
  let error: NASAError
  
  enum CodingKeys: String, CodingKey {
    case
    error
  }
}

struct NASAError: Codable {
  
  let code: String
  let message: String
  
  enum CodingKeys: String, CodingKey {
    case
    code,
    message
  }
}
