//
//  SpaceXAPIController.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

enum SpaceXEndpoint: String, APIEndpoint {
  case
  launches,
  latest
  
  static var baseURLString:String {
    return "https://api.spacexdata.com/v2"
  }
  
  /// The URL to fetch data about all launches.
  static var allLaunches: URL {
    return self.urlFromStringPieces([
        self.baseURLString,
        self.launches.rawValue,
      ])
  }
    
  /// The url to fetch data about the most recent launch
  static var latestLaunch: URL {
    return self.urlFromStringPieces([
        self.baseURLString,
        self.launches.rawValue,
        self.latest.rawValue,
      ])
  }
}

struct SpaceXAPIController {
  
  /// Fetches a list of all launches SpaceX has conducted.
  ///
  /// - Parameters:
  ///   - errorCompletion: The completion closure to execute on any error.
  ///                      Parameter is the error which occurred.
  ///   - successCompletion: The completion closure to execute on success.
  ///                        Parameter is an array of launches
  /// - Returns: The created task for cancellation.
  @discardableResult
  static func fetchAllLaunches(errorCompletion: @escaping (Error) -> Void,
                        successCompletion: @escaping ([SpaceXLaunch]) -> Void) -> URLSessionTask? {
    return NetworkDataFetcher.fetchData(from: SpaceXEndpoint.allLaunches,
                                        errorCompletion: errorCompletion,
                                        successCompletion: {
                                          data in
                                          
                                          do {
                                            let launches = try SpaceXDecoder.shared.decode([SpaceXLaunch].self, from: data)
                                            successCompletion(launches)
                                          } catch let error {
                                            errorCompletion(error)
                                          }
                                        })
  }
}
