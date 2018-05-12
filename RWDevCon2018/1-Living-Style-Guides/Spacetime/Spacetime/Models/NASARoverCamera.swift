//
//  NASARoverCamera.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

struct NASARoverCamera: Codable {
  let name: String
  let fullName: String
  
  enum CodingKeys: String, CodingKey {
    case
    name,
    fullName = "full_name"
  }
}
