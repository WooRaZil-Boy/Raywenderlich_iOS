//
//  CamperServiceTests.swift
//  CampgroundManagerTests
//
//  Created by 근성가이 on 2018. 3. 19..
//  Copyright © 2018년 Razeware. All rights reserved.
//

import XCTest
import CampgroundManager
import CoreData

class CamperServiceTests: XCTestCase { //XCTestCase 클래스를 생성하고, 필요한 메서드를 작성해 놓으면 테스트 한다.
  // MARK: Properties
  var camperService: CamperService!
  var coreDataStack: CoreDataStack!
  //Properties들은 setUp에서 초기화 된다. 따라서 여기서는 foreced unwrapping이 필요하다.
    
    override func setUp() { //속성은 여기서 초기화된다.
      //setUp()은 각 테스트가 실행되기 전에 호출된다.
      //필요한 리소스들을 생성한다(여기서는 속성 초기화).
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
      coreDataStack = TestCoreDataStack()
      camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
      //TestCoreDataStack의 context가 생성된다. //메모리 저장소
    }
    
    override func tearDown() {
      //tearDown()은 setUp()과 반대이다. 각 테스트가 실행 된 후 호출된다.
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
      
      camperService = nil
      coreDataStack = nil
    }
  
  func testAddCamper() { //동기로 처리
    let camper = camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
    //테스트 진행할 temp caper 생성 추가
    
    XCTAssertNotNil(camper, "Camper should not be nil") //camper가 nil이 되어서는 안된다.
    XCTAssertTrue(camper?.fullName == "Bacon Lover") //camper의 해당 속성이 제대로 들어가야 한다.
    XCTAssertTrue(camper?.phoneNumber == "910-543-9000") //camper의 해당 속성이 제대로 들어가야 한다.
  }
  
  func testRootContextIsSavedAfterAddingCamper() { //비동기로 처리
    //CoreData에서 하나의 managed object context를 사용할 때는 메인 쓰레드에서 실행 된다.
    //하지만, 별도의 개인 큐 컨텍스트를 만들어 다른 스레드에서 실행할 수도 있다.
    //performBlockAndWait(), performBlock()으로 래핑해서 사용하면 된다.
    let derivedContext = coreDataStack.newDerivedContext()
    //메인 컨텍스트 대신 새로운 newBackgroundContext 생성
    camperService = CamperService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
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
      let camper = self.camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000") //테스트 진행할 temp caper 생성 추가
      XCTAssertNotNil(camper) //nil이 아니어야 한다.
    }
    
    waitForExpectations(timeout: 2.0) { error in //테스트는 2초간 기다린다. 오류가 있거나 시간 초과되면 오류로 처리한다.
      XCTAssertNil(error, "Save did not occur")
    }
    //메인 스레드를 사용하지 않고 유닛 테스트를 진행하므로, 비동기 작업의 확인에 유용하다.
  }
}

//모듈의 타겟을 CampgroundManagerTests로 설정해야 한다.

//단위 테스트(Unit Test)는 앱을 작은 모듈의 모음으로 디자인할 때 효과적이다.
//하나의 뷰 컨트롤러에 모든 비즈니스 로직을 넣기보다, 클래스를 만들어 해당 로직을 캡슐화하는 것이 좋다.
//대부분의 경우 부분적으로 완료된 응용 프로그램에 단위 테스트를 추가한다.
