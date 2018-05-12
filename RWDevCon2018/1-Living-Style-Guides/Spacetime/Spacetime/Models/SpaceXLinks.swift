//
//  SpaceXLinks.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

struct SpaceXLinks: Codable {
  let missionPatchImage: String
  let article: String?
  let video: String?
  let pressKit: String?
  
  enum CodingKeys: String, CodingKey {
    case
    missionPatchImage = "mission_patch",
    article = "article_link",
    video = "video_link",
    pressKit = "presskit"
  }  
}
