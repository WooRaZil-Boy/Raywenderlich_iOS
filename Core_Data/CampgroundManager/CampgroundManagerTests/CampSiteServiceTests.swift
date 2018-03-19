//
//  CampSiteServiceTests.swift
//  CampgroundManagerTests
//
//  Created by 근성가이 on 2018. 3. 19..
//  Copyright © 2018년 Razeware. All rights reserved.
//

import UIKit
import XCTest
import CampgroundManager
import CoreData

class CampSiteServiceTests: XCTestCase {
  // MARK: Properties
  var campSiteService: CampSiteService!
  var coreDataStack: CoreDataStack!
  //Properties들은 setUp에서 초기화 된다. 따라서 여기서는 foreced unwrapping이 필요하다.
    
    override func setUp() {
      //setUp()은 각 테스트가 실행되기 전에 호출된다.
      //필요한 리소스들을 생성한다(여기서는 속성 초기화).
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
      coreDataStack = TestCoreDataStack()
      campSiteService = CampSiteService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
      //TestCoreDataStack의 context가 생성된다. //메모리 저장소
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
      //tearDown()은 setUp()과 반대이다. 각 테스트가 실행 된 후 호출된다.
        super.tearDown()
      
      campSiteService = nil
      coreDataStack = nil
    }
  
  func testAddCampSite() { //동기
    let campSite = campSiteService.addCampSite(1, electricity: true, water: true) //테스트 진행할 temp campSite 생성 추가
    
    XCTAssertTrue(campSite.siteNumber == 1, "Site number should be 1") //campSite의 해당 속성이 제대로 들어가야 한다.
    XCTAssertTrue(campSite.electricity!.boolValue, "Site should have electricity")
    XCTAssertTrue(campSite.water!.boolValue, "Site should have water")
  }
  
  func testRootContextIsSavedAfterAddingCampsite() { //비동기
    //CoreData에서 하나의 managed object context를 사용할 때는 메인 쓰레드에서 실행 된다.
    //하지만, 별도의 개인 큐 컨텍스트를 만들어 다른 스레드에서 실행할 수도 있다.
    //performBlockAndWait(), performBlock()으로 래핑해서 사용하면 된다.
    let derivedContext = coreDataStack.newDerivedContext()
    //메인 컨텍스트 대신 새로운 newBackgroundContext 생성
    campSiteService = CampSiteService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
    //newBackgroundContext로 새로운 managed object 생성
    expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave.rawValue, object: coreDataStack.mainContext) { notification in
      //notification에 연결된 expectation을 작성한다.
      //performBlock()은 테스트 상태 신호를 외부로 보내야 하는데, XCTestCase의 expectation은 이를 지원해 준다.
      //http://seorenn.blogspot.kr/2016/11/xcode-asynchronous-unittest.html
      return true
      //fulfill()은 비동기로 호출되는 완료 핸들러(클로저) 내에서 실행 되어 waitForExpectations에 신호를 보내 준다.
      //하지만, 예상치 못하게 타임아웃되는 경우도 있으므로, nofitication을 보내주는 식으로 구현하는 것이 더 쉽다.
      //nofitication은 해당 알림(컨텍스트 저장 완료)를 받으면 예상대로 수행된 것이기에 단순히 true만 반환해주면 된다.
    }
    
    derivedContext.perform { //newBackgroundContext에서 managed object를 추가하는 작업 실행
      let campSite = self.campSiteService.addCampSite(1, electricity: true, water: true) //테스트 진행할 temp campSite 생성 추가
      XCTAssertNotNil(campSite) //nil이 아니어야 한다.
    }
    
    waitForExpectations(timeout: 2.0) { error in //테스트는 2초간 기다린다. 오류가 있거나 시간 초과되면 오류로 처리한다.
      XCTAssertNil(error, "Save did not occur")
    }
    //메인 스레드를 사용하지 않고 유닛 테스트를 진행하므로, 비동기 작업의 확인에 유용하다.
  }
  
  func testGetCampSiteWithMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true) //테스트 진행할 temp campSite 생성 추가
    let campSite = campSiteService.getCampSite(1) //id로 검색
    XCTAssertNotNil(campSite, "A campsite should be returned") //nil이 반환되어서는 안된다.
  }
  
  func testGetCampSiteNoMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true) //테스트 진행할 temp campSite 생성 추가
    let campSite = campSiteService.getCampSite(2) //id로 검색
    XCTAssertNil(campSite, "No campsite should be returned") //nil이 반환되어야 한다.
  }
}

//TDD (Test-Driven Development)는 먼저 테스트를 작성한 다음 테스트가 통과될 때까지 점진적으로 기능을 구현하여 응용프로그램을 개발하는 방법이다.
//테스트를 해서 오류가 나는 부분을 찾아 코드를 수정하고, 테스트가 통과한 경우에만 다음 기능을 구현한다.
