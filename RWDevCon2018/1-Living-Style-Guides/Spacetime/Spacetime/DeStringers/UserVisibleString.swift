//
//  UserVisibleString.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

/*
 Centralized storage of user-visible strings for reusability.
 
 Will also make it easier to switch the underlying values to localized strings
 in the future, since they're already abstracted out of the main codebase.
 
 Stored as an enum so they can't accidentally be instantiated.
 */
enum UserVisibleString {
  
  private static let mediumDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    return dateFormatter
  }()
  
  private static let longDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    return dateFormatter
  }()
  
  //MARK: - Simple strings
  
  static let NASA = "NASA"
  static let SpaceX = "SpaceX"
  static let succeeded = "succeeded"
  static let failed = "failed"
  static let NASASummary = "NASA is a U.S. government science agency which has been landing research rovers on Mars since 2003. This is a summary of the NASA rovers on Mars, and their current statuses."
  static let SpaceXSummary = "SpaceX is a commercial company with a goal of reusing as much of a rocket as possible to reduce the cost of spaceflight. They've been launching rockets successfully since 2008. This is a summary of their attempts at launching and landing rockets."
  static let loading = "Loading..."
  
  //MARK: - Strings which can be composed out of the standard library types
  
  static func launchDateString(for date: Date) -> String {
    return self.launchDateString(for: date, using: self.mediumDateFormatter)
  }
  
  static func longLaunchDateString(for date: Date) -> String {
    return self.launchDateString(for: date, using: self.longDateFormatter)
  }
  
  private static func launchDateString(for date: Date, using formatter: DateFormatter) -> String {
    let formattedDate = formatter.string(from: date)
    return "Launched on \(formattedDate)"
  }
  
  static func lastPhotoDateString(for date: Date) -> String {
    let formattedDate = self.mediumDateFormatter.string(from: date)
    return "Most recent photo taken \(formattedDate)"
  }
  
  private static func statusWord(for success: Bool) -> String {
    if success {
      return self.succeeded
    } else {
      return self.failed
    }
  }
  
  static func launchStatusString(for success: Bool) -> String {
    let statusWord = self.statusWord(for: success)
    return "Launch \(statusWord)"
  }
  
  static func landingStatusString(for success: Bool) -> String {
    let statusWord = self.statusWord(for: success)
    return "Landing \(statusWord)"
  }
  
  static func launchString(for date: Date, and location: String) -> String {
    let dateString = self.mediumDateFormatter.string(from: date)
    return "Launched \(dateString) from \(location)"
  }
  
  static func launchTitleString(for launchNumber: Int, and rocketName: String) -> String {
    return "Launch #\(launchNumber): \(rocketName)"
  }
  
  static func boosterRecycledEmoji(for wasRecycled: Bool) -> String {
    if wasRecycled {
      return "♻️"
    } else {
      return "🆕"
    }
  }
  
  static func boosterRecycledString(for wasRecycled: Bool) -> String {
    if wasRecycled {
      return "Reused booster"
    } else {
      return "Brand new booster"
    }
  }
  
  static func landingTargetString(for landing: String) -> String {
    return "Landing target: \(landing)"
  }
  
  static func fetchingMostRecentPhotoInfo(for roverName: String, cameraName: String) -> String {
    return "Fetching most recent photo info for \(roverName)'s \(cameraName)..."
  }
  
  static func mostRecentPhoto(for cameraName: String) -> String {
    return "Most recent \(cameraName) photo:"
  }
  
  static func takenOn(earthDate: Date, sol: Int) -> String {
    return "Taken on \(self.longDateFormatter.string(from: earthDate)) (Sol \(sol))"
  }
  
  static func cameras(for roverName: String) -> String {
    return "\(roverName)'s cameras"
  }
  
  static func noPhotoAvailable(for roverName: String, cameraName: String, inSols sols: Int) -> String {
    return "No photo available for \(roverName)'s \(cameraName) in the last \(sols) Martian sols."
  }
}
