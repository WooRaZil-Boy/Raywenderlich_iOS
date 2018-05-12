//
//  String+CamelCaseToSpacing.swift
//  SpacetimeUI
//
//  Created by Ellen Shapiro on 2/4/18.
//  Copyright © 2018 RayWenderlich.com. All rights reserved.
//

import Foundation


extension String {
  
  func camelCaseToSpacing() -> String {
    // There is almost certainly a better way to do this. 
    let strings = self.reduce([""], {
      strings, character in
      
      guard var last = strings.last else {
        return strings
      }
      
      let regularChar = String(character)
      let uppercasedChar = String(character).uppercased()
      
      var updatedStrings = strings
      if regularChar == uppercasedChar {
        last = ""
        updatedStrings.append(last)
      }
      
      let lastIndex = updatedStrings.count - 1
      last += regularChar
      
      updatedStrings[lastIndex] = last
      
      
      return updatedStrings
      
    })
    
    let allCapitalized = strings
      .filter { !$0.isEmpty }
      .map { $0.capitalized }
    
    return allCapitalized.joined(separator: " ")
    
  }
  
}
