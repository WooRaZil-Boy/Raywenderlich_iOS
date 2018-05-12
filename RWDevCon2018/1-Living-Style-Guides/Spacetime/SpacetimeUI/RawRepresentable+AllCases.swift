//
//  RawRepresentable+AllCases.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation

extension RawRepresentable {
  public static var allCases: [Self] {
    var caseIndex: Int = 0
    // Create an iterator
    let generator: AnyIterator<Self> = AnyIterator {
      // In which each time it goes around, the case index is used
      let current: Self = withUnsafePointer(to: &caseIndex) {
        // To grab the appropriate memory for one of this type, and grab it's pointee
        $0.withMemoryRebound(to: Self.self, capacity: 1) { $0.pointee }
      }
      caseIndex += 1
      return current // TODO: Figure out why this infinite loops with single cases
    }
    return Array(generator)
  }
}
