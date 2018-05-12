//
//  SpacetimeTests.swift
//  SpacetimeTests
//
//  Created by Ellen Shapiro on 10/22/17.
//  Copyright © 2017 RayWenderlich.com. All rights reserved.
//

import XCTest
@testable import Spacetime

class SpacetimeTests: XCTestCase {
  
  func testFetchingRovers() {
    let roverExpectation = self.expectation(description: "rover call completed")
    var retrievedRovers: [NASAMarsRover]?
    NASAAPIController.fetchListOfRovers(errorCompletion: {
                                          error in
                                          XCTFail("Rover call failed with error: \(error)")
                                          roverExpectation.fulfill()
                                        },
                                        successCompletion: {
                                          rovers in
                                          retrievedRovers = rovers
                                          
                                          XCTAssertEqual(rovers.count, 3)
                                          
                                          let alphebetizedNames = rovers.map { $0.name }.sorted()
                                          let expectedNames = [
                                            "Curiosity",
                                            "Opportunity",
                                            "Spirit"
                                          ]
                                          XCTAssertEqual(alphebetizedNames, expectedNames)
                                          
                                          roverExpectation.fulfill()
                                        })
    
    self.wait(for: [roverExpectation], timeout: 10)
    
    guard
      let rovers = retrievedRovers,
      let curiosity = rovers.first,
      let camera = curiosity.cameras.first else {
        XCTFail("Couldn't get curiosity or its first camera")
        return
    }
    
    // Check fetching photos with just curiosity since it should always have recent photos.
    let photosExpectation = self.expectation(description: "Photos call for Curiosity")
    NASAAPIController.fetchMostRecentPhoto(for: curiosity,
                                           takenWith: camera,
                                           errorCompletion: {
                                            error in
                                            XCTFail("Error getting photos for Curiosity's \(camera.fullName): \(error)")
                                            photosExpectation.fulfill()
                                           },
                                           successCompletion: {
                                            photo in
                                            XCTAssertFalse(photo.imageURLString.isEmpty)
                                            photosExpectation.fulfill()
                                           })
    self.wait(for: [photosExpectation], timeout: 10)
  }

  
  func testFetchingAllLaunches() {
    let launchExpectation = self.expectation(description: "launch call completed")
    
    SpaceXAPIController.fetchAllLaunches(errorCompletion: {
                                          error in
                                          XCTFail("Error getting all launches: \(error)")
                                          launchExpectation.fulfill()
                                         },
                                         successCompletion: {
                                          
                                          launches in
                                          // There were 49 launches at the time this was written, so there should be
                                          // *at least* that many returned thereafter
                                          XCTAssertGreaterThanOrEqual(launches.count, 49)
                                          launchExpectation.fulfill()
                                         })
    
    self.wait(for: [launchExpectation], timeout: 10)
  }
}
