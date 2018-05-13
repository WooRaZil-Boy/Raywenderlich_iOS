// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation
 
// Required by Swift 4 and earlier.
func ==(lhs: Sols, rhs: Sols) -> Bool {
  return lhs.value == rhs.value
}
func ==(lhs: Photo, rhs: Photo) -> Bool {
  return lhs.url == rhs.url && lhs.camera == rhs.camera && lhs.time == rhs.time
}
func ==(lhs: Rover, rhs: Rover) -> Bool {
  return lhs.name == rhs.name && lhs.photos == rhs.photos
}
