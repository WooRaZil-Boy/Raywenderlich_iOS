//
//  SpaceXRocket.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

struct SpaceXRocket: Codable {
  let id: String
  let name: String
  let type: String
  let firstStage: SpaceXFirstStage
  let secondStage: SpaceXSecondStage
  
  enum CodingKeys: String, CodingKey {
    case
    id = "rocket_id",
    name = "rocket_name",
    type = "rocket_type",
    firstStage = "first_stage",
    secondStage = "second_stage"
  }
}
