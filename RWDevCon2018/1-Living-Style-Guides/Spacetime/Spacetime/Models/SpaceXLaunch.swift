//
//  SpaceXLaunch.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

struct SpaceXLaunch: Codable {
  
  let flightNumber: Int
  let launchYear: String
  let launchDate: Date
  let rocket: SpaceXRocket
  let launchSite: SpaceXLaunchSite
  let launchSucceeded: Bool
  let links: SpaceXLinks
  let details: String?
  
  enum CodingKeys: String, CodingKey {
    case
    flightNumber = "flight_number",
    launchYear = "launch_year",
    launchDate = "launch_date_utc",
    rocket,
    launchSite = "launch_site",
    launchSucceeded = "launch_success",
    links,
    details
  }
  
  var reusedLaunchVehicle: Bool {
    return rocket.firstStage.cores.first?.reusedLaunchVehicle ?? false
  }
  
  var landingSucceeded: Bool {
    return rocket.firstStage.cores.first?.landingSucceeded ?? false
  }
  
  var landingType: LandingType? {
    return rocket.firstStage.cores.first?.landingType
  }
  
  var landingVehicle: LandingVehicle? {
    return rocket.firstStage.cores.first?.landingVehicle
  }
  
}
