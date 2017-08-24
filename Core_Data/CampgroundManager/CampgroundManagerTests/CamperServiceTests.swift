//
//  CamperServiceTests.swift
//  CampgroundManager
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 Razeware. All rights reserved.
//

import XCTest
import CampgroundManager
import CoreData

class CamperServiceTests: XCTestCase {
  
  // MARK: Properties
  var camperService: CamperService!
  var coreDataStack: CoreDataStack!
    
    override func setUp() { //테스트가 시작 되기 전 //초기화
        super.setUp()
      
      coreDataStack = TestCoreDataStack()
      camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() { //테스트가 실행된 후
        super.tearDown()
      
      camperService = nil
      coreDataStack = nil
    }
  
  func testAddCamper() {
    let camper = camperService.addCamper("Bacon Lover",
                                         phoneNumber: "910-543-9000")
    XCTAssertNotNil(camper, "Camper should not be nil") //객체가 nil이 아닌지 테스트 //XCTAssertNil은 반대
    XCTAssertTrue(camper?.fullName == "Bacon Lover") //True 테스트
    XCTAssertTrue(camper?.phoneNumber == "910-543-9000")
  }
  
  func testRootContextIsSavedAfterAddingCamper() { //비동기화 테스트
    let derivedContext = coreDataStack.newDerivedContext() //작업 영역 정의
    camperService = CamperService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
    
    expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave.rawValue, object: coreDataStack.mainContext) { notification in //알림 처리 //비동기 테스트
        return true
    }
    
    let camper = camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
    XCTAssertNotNil(camper)
    
    waitForExpectations(timeout: 2.0) { error in //시간이 지난 후 실행. //비동기로 진행되는 테스크를 체크할 수 있다.
      XCTAssertNil(error, "Save did not occur")
    }
  }
}
