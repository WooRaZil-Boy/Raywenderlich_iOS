//
//  DepartmentListViewControllerTests.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import XCTest
@testable import EmployeeDirectory

class DepartmentListViewControllerTests: XCTestCase {
    func testTotalEmployeesPerDepartment() { //유닛 테스트를 꼭 실행 여부나 제대로 된 값이 들어갔는지 뿐 아니라 이런 식으로 실행 시간 등을 확인해 볼 수도 있다.
        measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
            let departmentList = DepartmentListViewController()
            departmentList.coreDataStack = CoreDataStack(modelName: "EmployeeDirectory") //캐싱되므로 새로운 코어 데이터 스택을 설정해서 테스트 해야 한다.
            self.startMeasuring() //코드의 실행 시간을 확인한다.
            _ = departmentList.totalEmployeesPerDepartment()
            self.stopMeasuring() //startMeasuring와 쌍을 이룬다.
        }
    }
    
    func testTotalEmployeesPerDepartmentFast() {
        measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
            let departmentList = DepartmentListViewController()
            departmentList.coreDataStack = CoreDataStack(modelName: "EmployeeDirectory") //캐싱되므로 새로운 코어 데이터 스택을 설정해서 테스트 해야 한다.
            self.startMeasuring() //코드의 실행 시간을 확인한다.
            _ = departmentList.totalEmployeesPerDepartmentFast()
            self.stopMeasuring() //startMeasuring와 쌍을 이룬다.
        }
    }
}
