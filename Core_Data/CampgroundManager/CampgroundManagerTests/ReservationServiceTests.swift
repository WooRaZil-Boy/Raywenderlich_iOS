//
//  ReservationServiceTests.swift
//  CampgroundManagerTests
//
//  Created by 근성가이 on 2018. 3. 19..
//  Copyright © 2018년 Razeware. All rights reserved.
//

import Foundation
import CoreData
import XCTest
import CampgroundManager

class ReservationServiceTests: XCTestCase {
  // MARK: Properties
  var campSiteService: CampSiteService!
  var camperService: CamperService!
  var reservationService: ReservationService!
  var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
      //필요한 리소스들을 생성한다(여기서는 속성 초기화).
      coreDataStack = TestCoreDataStack() //메모리 저장소
      camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
      campSiteService = CampSiteService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
      reservationService = ReservationService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
      //TestCoreDataStack의 context로 생성된다. //메모리 저장소
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
      
      camperService = nil
      campSiteService = nil
      reservationService = nil
      coreDataStack = nil
    }
  
  func testReserveCampSitePositiveNumberOfDays() {
    let camper = camperService.addCamper("Johnny Appleseed", phoneNumber: "408-555-1234")! //temp camper 생성
    let campSite = campSiteService.addCampSite(15, electricity: false, water: false) //temp camper site 생성
    let result = reservationService.reserveCampSite(campSite, camper: camper, date: Date(), numberOfNights: 5)
    //camp reservation 생성
    
    XCTAssertNotNil(result.reservation, "Reservation should not be nil")
    XCTAssertNil(result.error, "No error should be present")
    XCTAssertTrue(result.reservation?.status == "Reserved", "Status should be Reserved")
    //해당 부분들 별로 테스트
  }
  
  func testReserveCampSiteNegativeNumberOfDays() {
    let camper = camperService.addCamper("Johnny Appleseed", phoneNumber: "408-555-1234")! //temp camper 생성
    let campSite = campSiteService.addCampSite(15, electricity: false, water: false) //temp camper site 생성
    let result = reservationService.reserveCampSite(campSite, camper: camper, date: Date(), numberOfNights: -1)
    //camp reservation 생성
    
    XCTAssertNotNil(result.reservation, "Reservation should not be nil")
    XCTAssertNotNil(result.error, "An error should be present")
    XCTAssertTrue(result.error?.userInfo["Problem"] as? String == "Invalid number of days", "Error problem should be present")
    XCTAssertTrue(result.reservation?.status == "Invalid", "Status should be Invalid")
  }
}

//CoreData와 같은 DB 로직은 복잡해서, 디버깅 하기 쉽지 않은 경우가 많다. 그런 경우 Unit Test가 도움이 된다.
