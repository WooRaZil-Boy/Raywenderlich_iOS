//
//  NASAAPIController.swift
//  Spacetime
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import Foundation

/*
 Documentation of the endpoints is available via https://api.nasa.gov/api.html#MarsPhotos
 */
enum NASAEndpoint: String, APIEndpoint {
  case
  rovers,
  manifests,
  photos
  
  static var baseURLString: String {
    return "https://api.nasa.gov/mars-photos/api/v1"
  }
  
  static let APIKeyParam = "?api_key=ww42AtNmVnzEfjS2yUQ1Ym1RXK0jtp7iivwuVhWF"
  static let SolParamName = "sol"
  static let CameraParamName = "camera"
  
  /// How many Martian sols should we be trying to query for a "recent" photo from one of the rover cams? 
  static let SolsToQuery: Int = 7
  
  var fullEndpoint: URL {
    return NASAEndpoint.urlFromStringPieces([
        NASAEndpoint.baseURLString,
        self.rawValue,
        NASAEndpoint.APIKeyParam,
      ])
  }
  
  static func manifestEnpointForRover(_ name: String) -> URL {
    return self.urlFromStringPieces([
        NASAEndpoint.baseURLString,
        NASAEndpoint.manifests.rawValue,
        name,
        NASAEndpoint.APIKeyParam,
      ])
  }
  
  static func photoEndpointForRover(_ name: String,
                                    sol: Int,
                                    cameraName: String) -> URL {
    return self.urlFromStringPieces([
        NASAEndpoint.baseURLString,
        NASAEndpoint.rovers.rawValue,
        name,
        NASAEndpoint.photos.rawValue,
        NASAEndpoint.APIKeyParam,
      ]).appendingParameters([
        URLQueryItem(name: NASAEndpoint.SolParamName, value: "\(sol)"),
        URLQueryItem(name: NASAEndpoint.CameraParamName, value: cameraName),
      ])
  }
}

struct NASAAPIController {
  
  /// Fetches and parses a list of the available rovers on Mars.
  ///
  /// - Parameters:
  ///   - errorCompletion: The completion closure to fire on any error.
  ///   - successCompletion: The completion closure to fire if the operation succeeds.
  ///                        Parameter is an array of available rovers.
  /// - Returns: The task for optional cancellation
  @discardableResult
  static func fetchListOfRovers(errorCompletion: @escaping (Error) -> Void,
                                successCompletion: @escaping ([NASAMarsRover]) -> Void) -> URLSessionTask? {
    
    return NetworkDataFetcher.fetchData(from: NASAEndpoint.rovers.fullEndpoint,
                                        errorCompletion: errorCompletion,
                                        successCompletion: {
                                          data in                                          
                                          do {
                                            let container = try NASADecoder.shared.decode(RoverWrapper.self, from: data)
                                            successCompletion(container.rovers)
                                          } catch let error {
                                            if let errorContainer = try? NASADecoder.shared.decode(ErrorWrapper.self, from: data) {
                                              NSLog("Error from NASA: \(errorContainer.error.message)")
                                            }
                                            errorCompletion(error)
                                          }
                                        })
  }
  
  static func recentPhotoNotAvailableError(for roverName: String, camera: NASARoverCamera) -> Error {
    let error = NSError(domain: "com.raywenderlich.spacetime", code: 404, userInfo: [NSLocalizedDescriptionKey : UserVisibleString.noPhotoAvailable(for: roverName, cameraName: camera.fullName, inSols: NASAEndpoint.SolsToQuery)])
    return error as Error
  }
  
  /// Attempts to fetch the most recent photo for a given rover's given camera.
  /// NOTE: Due to NASA rate-limiting, this will error out if no photo is found 7 sols in the past.
  ///
  /// - Parameters:
  ///   - rover: The rover to use for the query
  ///   - camera: The camera to use for the query
  ///   - errorCompletion: The completion closure to execute on any error
  ///   - successCompletion: The completion closure to execute when a photo is found - 
  static func fetchMostRecentPhoto(for rover: NASAMarsRover,
                                   takenWith camera: NASARoverCamera,
                                   errorCompletion: @escaping (Error) -> Void,
                                   successCompletion: @escaping (NASARoverPhoto) -> Void) {
    if PhotoCache.isPhotoDefinitelyUnavailable(for: rover.name, cameraName: camera.name) == true {
      // Don't waste any more API requests trying to fetch an unavailable photo.
      errorCompletion(self.recentPhotoNotAvailableError(for: rover.name, camera: camera))
      return
    }
    
    if let cachedPhotoData = PhotoCache.photoData(for: rover.name, cameraName: camera.name) {
      // Don't waste any more API requests trying to fetch data we already have.
      successCompletion(cachedPhotoData)
      return
    }
    
    // If we got here, time to go to the interwebs
    self.fetchPhoto(on: rover.mostRecentMartianSolForPhotos,
                    remainingSols: NASAEndpoint.SolsToQuery,
                    for: rover.name,
                    takenWith: camera,
                    errorCompletion: errorCompletion,
                    successCompletion: successCompletion)
  }
  
  private static func fetchPhoto(on sol: Int,
                                 remainingSols: Int,
                                 for roverName: String,
                                 takenWith camera: NASARoverCamera,
                                 errorCompletion: @escaping (Error) -> Void,
                                 successCompletion: @escaping (NASARoverPhoto) -> Void) {
    guard remainingSols > 0 else {
      PhotoCache.cachePhotoUnavailable(for: roverName, cameraName: camera.name)
      errorCompletion(self.recentPhotoNotAvailableError(for: roverName, camera: camera))
      return
    }
    
    let endpoint = NASAEndpoint.photoEndpointForRover(roverName,
                                                      sol: sol,
                                                      cameraName: camera.name)
    
    let _ = NetworkDataFetcher.fetchData(from: endpoint,
                                         errorCompletion: errorCompletion,
                                         successCompletion: {
                                          data in
                                          
                                          do {
                                            let container = try NASADecoder.shared.decode(PhotoWrapper.self, from: data)
                                            if let first = container.photos.first {
                                              PhotoCache.cachePhotoData(photo: first,
                                                                        for: roverName,
                                                                        cameraName: camera.name)
                                              successCompletion(first)
                                            } else {
                                              // Look for the previous sol
                                              self.fetchPhoto(on: sol - 1,
                                                              remainingSols: remainingSols - 1,
                                                              for: roverName,
                                                              takenWith: camera,
                                                              errorCompletion: errorCompletion,
                                                              successCompletion: successCompletion)
                                            }
                                          } catch let error {
                                            errorCompletion(error)
                                          }
                                         })
  }
}

// MARK - Caching

/// UserDefaults based cache to help avoid rate limiting on photo fetches
private struct PhotoCache {
  
  static func cachePhotoData(photo: NASARoverPhoto, for roverName: String, cameraName: String) {
    let data = try? JSONEncoder().encode(photo)
    UserDefaults.standard.set(data, forKey: "\(roverName)_\(cameraName)")
  }
  
  static func photoData(for roverName: String, cameraName: String) -> NASARoverPhoto? {
    guard let data = UserDefaults.standard.data(forKey: "\(roverName)_\(cameraName)") else {
      return nil
    }
      
    return try? JSONDecoder().decode(NASARoverPhoto.self, from: data)
  }
  
  static func cachePhotoUnavailable(for roverName: String, cameraName: String) {
    UserDefaults.standard.set(true, forKey: "\(roverName)_\(cameraName)_unavailable")
  }
  
  static func isPhotoDefinitelyUnavailable(for roverName: String, cameraName: String) -> Bool {
    return UserDefaults.standard.bool(forKey: "\(roverName)_\(cameraName)_unavailable")
  }
}
