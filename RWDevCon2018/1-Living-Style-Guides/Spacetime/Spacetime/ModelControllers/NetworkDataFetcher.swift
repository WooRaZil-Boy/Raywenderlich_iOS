//
//  NetworkDataFetcher.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

enum NetworkError: Error {
  case
  dataCouldNotBeLoaded,
  noErrorAndNoData,
  noHost,
  noLocalDataForThisHost
  
}

struct NetworkDataFetcher {
  
  /// Set to false to return data from the "offline" folder. Emergency backup in case of terrible wifi.
  static var useRealNetwork = true
  
  /// An abstraction because I always forget to call `resume` when I'm using NSURLSession directly.
  /// Also to break out success/failure more clearly and encapsulate threading.
  ///
  /// - Parameters:
  ///   - url: The URL to fetch data from
  ///   - errorComletion: The completion closure to execute on any error.
  ///                     Parameter is the encountered error.
  ///   - successCompletion: The completion closure to execute on success.
  ///                        Parameter is the retrieved data
  /// - Returns: The created URLSession task (if one was created) so it can be cancelled if needed.
  static func fetchData(from url: URL,
                        errorCompletion: @escaping (Error) -> Void,
                        successCompletion: @escaping (Data) -> Void) -> URLSessionTask? {
    
    guard useRealNetwork else {
      fetchDataFromFile(forURL: url,
                        errorCompletion: errorCompletion,
                        successCompletion: successCompletion)
      return nil
    }
    
    let task = URLSession.shared.dataTask(with: url) {
      data, urlResponse, error in
      
      DispatchQueue.main.async {
        if let networkError = error {
          errorCompletion(networkError)
          return
        }
        
        if let returnedData = data {
          successCompletion(returnedData)
          return
        }
        
        errorCompletion(NetworkError.noErrorAndNoData)
      }
   }
    
    task.resume()
    return task
  }
  
  private static func fetchDataFromFile(forURL url: URL,
                                        errorCompletion: @escaping (Error) -> Void,
                                        successCompletion: @escaping (Data) -> Void) {
    guard let host = url.host else {
      errorCompletion(NetworkError.noHost)
      return
    }
    
    var dataPath: String?
    switch host {
    case "api.nasa.gov":
      dataPath = Bundle.main.path(forResource: "nasa", ofType: "json")
    case "api.spacexdata.com":
      dataPath = Bundle.main.path(forResource: "spacex", ofType: "json")
    default:
      dataPath = nil
    }
    
    guard let path = dataPath else {
      errorCompletion(NetworkError.noLocalDataForThisHost)
      return
    }
    
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
      errorCompletion(NetworkError.dataCouldNotBeLoaded)
      return
    }
    
    successCompletion(data)
  }
}
