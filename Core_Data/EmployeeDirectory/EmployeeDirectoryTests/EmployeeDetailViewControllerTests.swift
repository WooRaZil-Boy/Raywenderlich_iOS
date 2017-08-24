//
//  EmployeeDetailViewControllerTests.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import XCTest
import CoreData
@testable import EmployeeDirectory

class EmployeeDetailViewControllerTests: XCTestCase {
  func testCountSales() {
    measureMetrics([XCTPerformanceMetric_WallClockTime],
                   automaticallyStartMeasuring: false) {

      let employee = self.getEmployee()
      let employeeDetails = EmployeeDetailViewController()
      self.startMeasuring()
      _ = employeeDetails.salesCountForEmployee(employee)
      self.stopMeasuring()
    }
  }
    
    func testCountSalesFast() {
        measureMetrics([XCTPerformanceMetric_WallClockTime],
                       automaticallyStartMeasuring: false) {
                        
                        let employee = self.getEmployee()
                        let employeeDetails = EmployeeDetailViewController()
                        self.startMeasuring()
                        _ = employeeDetails.salesCountForEmployeeFast(employee)
                        self.stopMeasuring()
        }
    }
    
    func testCountSalesSimple() {
        measureMetrics([XCTPerformanceMetric_WallClockTime],
                       automaticallyStartMeasuring: false) {
                        
                        let employee = self.getEmployee()
                        let employeeDetails = EmployeeDetailViewController()
                        self.startMeasuring()
                        _ = employeeDetails.salesCountForEmployeeSimple(employee)
                        self.stopMeasuring()
        }
    }

    func getEmployee() -> Employee {
        let coreDataStack = CoreDataStack(modelName: "EmployeeDirectory")

        let request: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")

        request.sortDescriptors = [NSSortDescriptor(key: "guid", ascending: true)]
        request.fetchBatchSize = 1
        let results: [AnyObject]?
        
        do {
          results = try coreDataStack.mainContext.fetch(request)
        } catch _ {
          results = nil
        }
        
        return results![0] as! Employee
    }
}
