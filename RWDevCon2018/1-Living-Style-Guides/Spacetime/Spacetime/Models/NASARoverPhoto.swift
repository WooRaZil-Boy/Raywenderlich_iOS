//
//  NASARoverPhoto.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

struct NASARoverPhoto: Codable {
  let id: Int
  let martianSol: Int
  let earthDate: Date
  let camera: NASARoverCamera
  let rover: NASAMarsRover
  let imageURLString: String
  
  enum CodingKeys: String, CodingKey {
    case
    id,
    martianSol = "sol",
    earthDate = "earth_date",
    camera,
    rover,
    imageURLString = "img_src"
  }
}

struct PhotoWrapper: Codable {
  
  let photos: [NASARoverPhoto]
  
  enum CodingKeys: String, CodingKey {
    case
    photos
  }
}
