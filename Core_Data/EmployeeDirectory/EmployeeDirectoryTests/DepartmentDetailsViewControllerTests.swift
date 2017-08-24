//
//  DepartmentDetailsViewControllerTests.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import XCTest
@testable import EmployeeDirectory

class DepartmentDetailsViewControllerTests: XCTestCase {
  func testTotalEmployeesFetchPerformance() {
    measureMetrics([XCTPerformanceMetric_WallClockTime],
                   automaticallyStartMeasuring: false) {

          let departmentDetails = DepartmentDetailsViewController()
          departmentDetails.coreDataStack = CoreDataStack(modelName: "EmployeeDirectory")
          self.startMeasuring()
          _ = departmentDetails.totalEmployees("Engineering")
          self.stopMeasuring()
        }
    }
}
