//
//  NASAMarsRover.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

enum RoverStatus: String, Codable {
  case
  active,
  complete
}

struct RoverWrapper: Codable {
  let rovers: [NASAMarsRover]
}

struct NASAMarsRover: Codable {
  let id: Int
  let name: String
  let launchDate: Date
  let landingDate: Date
  let status: RoverStatus
  let mostRecentMartianSolForPhotos: Int
  let mostRecentEarthDateForPhotos: Date
  let totalPhotosTaken: Int
  let cameras: [NASARoverCamera]
  
  enum CodingKeys: String, CodingKey {
    case
    id,
    name,
    launchDate = "launch_date",
    landingDate = "landing_date",
    status,
    mostRecentMartianSolForPhotos = "max_sol",
    mostRecentEarthDateForPhotos = "max_date",
    totalPhotosTaken = "total_photos",
    cameras
  }
}
