//
//  SpaceXStage.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 1/7/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation

struct SpaceXFirstStage: Codable {
  let cores: [SpaceXCoreInfo]
  
  enum CodingKeys: String, CodingKey {
    case
    cores
  }
}

struct SpaceXSecondStage: Codable {
  let payloads: [SpaceXPayload]
  
  enum CodingKeys: String, CodingKey {
    case
    payloads
  }
}
