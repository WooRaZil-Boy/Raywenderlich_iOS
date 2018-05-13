// Copyright (c) 2018 Razeware LLC
// For full license & permission details, see LICENSE.markdown.

import Foundation

func ==<Units>(lhs: Distance<Units>, rhs: Distance<Units>) -> Bool {
  return lhs.value == rhs.value
}

