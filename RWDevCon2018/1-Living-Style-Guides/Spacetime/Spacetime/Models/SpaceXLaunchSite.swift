//
//  SpaceXLaunchSite.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation
import CoreLocation

enum LaunchSite: String, Codable {
  case
  CCAF40 = "CCAFS SLC 40",
  Kwajalein = "Kwajalein Atoll",
  VAFB4E = "VAFB SLC 4E",
  KSC39A = "KSC LC 39A"
  
  var shortName: String {
    switch self {
    case .CCAF40:
      return "Cape Canaveral"
    case .KSC39A:
      return "Kennedy Space Center"
    case .VAFB4E:
      return "Vandenberg AFB"
    default:
      return self.rawValue
    }
  }
  
  var displayName: String {
    switch self {
    case .CCAF40:
      return "Cape Canaveral Pad 40"
    case .VAFB4E:
      return "Vandenberg Air Force Base Pad 4E"
    case .KSC39A:
      return "Kennedy Space Center Pad 39A"
    default:
      return self.rawValue
    }
  }

  var coordinate: CLLocationCoordinate2D {
    switch self {
    case .CCAF40:
      return CLLocationCoordinate2D(latitude: 28.561948,
                                    longitude: -80.577250)
    case .VAFB4E:
      return CLLocationCoordinate2D(latitude: 34.634361,
                                    longitude: -120.613009)
    case .KSC39A:
      return CLLocationCoordinate2D(latitude: 28.608206,
                                    longitude: -80.604136)
    case .Kwajalein:
      return CLLocationCoordinate2D(latitude: 9.048185,
                                    longitude: 167.743314)
    }
  }
  
}

struct SpaceXLaunchSite: Codable {
  let id: String
  let site: LaunchSite
  
  enum CodingKeys: String, CodingKey {
    case
    id = "site_id",
    site = "site_name"
  }
}
