//
//  SpaceXCoreInfo.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 1/7/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation

enum LandingVehicle: String, Codable {
  case
  LZ1 = "LZ-1",
  LZ2 = "LZ-2",
  JRTI,
  OCISLY
  
  var displayName: String {
    switch self {
    case .LZ1:
      return "Landing Zone 1"
    case .LZ2:
      return "Landing Zone 2"
    case .JRTI:
      return "Just Read The Instructions"
    case .OCISLY:
      return "Of Course I Still Love You"
    }
  }
}


enum LandingType: String, Codable {
  case
  Ocean, // It fell into the ocean
  ASDS, // Automatic Spaceport Drone Ship
  RTLS // Return to Launch Site
  
  var displayName: String {
    switch self {
    case .Ocean:
      return self.rawValue
    case .ASDS:
      return "Drone Ship"
    case .RTLS:
      return "Launch Site"
    }
  }
  
  var descriptionEmoji: String {
    switch self {
    case .Ocean:
      return "🌊"
    case .ASDS:
      return "🤖🚢"
    case .RTLS:
      return "🚀⬆️"
    }
  }
}

struct SpaceXCoreInfo: Codable {
  let serial: String
  let reusedLaunchVehicle: Bool
  let landingSucceeded: Bool?
  let landingType: LandingType?
  let landingVehicle: LandingVehicle?
  
  enum CodingKeys: String, CodingKey {
    case
    serial = "core_serial",
    landingSucceeded = "land_success",
    reusedLaunchVehicle = "reused",
    landingType = "landing_type",
    landingVehicle = "landing_vehicle"
  }
}
