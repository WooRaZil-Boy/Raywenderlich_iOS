//
//  SpaceXPayload.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 1/7/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation

enum Orbit: String, Codable {
  case
  ISS,
  LEO,
  GTO,
  Polar,
  ESL1 = "ES-L1",
  SSO,
  PO,
  HCO,
  HEO,
  Heliocentric = "Heliocentric orbit"
  
  var displayName: String {
    switch self {
    case .LEO:
      return "Lower Earth Orbit"
    case .ISS:
      return "International Space Station"
    case .ESL1:
      return "Earth-Sun Libration Point 1"
    case .GTO:
      return "Geostationary Transfer Orbit"
    case .Polar,
         .PO:
      return "Polar Orbit"
    case .SSO:
      return "Sun-Synchronous Orbit"
    case .Heliocentric,
         .HCO:
      return "Heliocentric Orbit"
    case .HEO:
      return "Highly Elliptical Orbit"
    }
  }
  
  
}

enum PayloadType: String, Codable {
  case
  satellite = "Satellite",
  dragonBoilerplate = "Dragon Boilerplate",
  dragon1_0 = "Dragon 1.0",
  dragon1_1 = "Dragon 1.1"
}

struct SpaceXPayload: Codable {
  let id: String
  let reused: Bool
  let customers: [String]
  let type: PayloadType
  let massInKilograms: Float?
  let massInPounds: Float?
  let orbit: Orbit
  
  enum CodingKeys: String, CodingKey {
    case
    id = "payload_id",
    reused,
    customers,
    type = "payload_type",
    massInKilograms = "payload_mass_kg",
    massInPounds = "payload_mass_lbs",
    orbit
  }
}
