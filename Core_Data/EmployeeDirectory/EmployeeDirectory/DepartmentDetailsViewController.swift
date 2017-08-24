//
//  DepartmentDetailsViewController.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class DepartmentDetailsViewController: UIViewController {
    //MARK: - Properties
    var coreDataStack: CoreDataStack!
    var department: String?
    
    //MARK: - IBOutlets
    @IBOutlet var totalEmployeesLabel: UILabel!
    @IBOutlet var activeEmployeesLabel: UILabel!
    @IBOutlet var greaterThanFifteenVacationDaysLabel: UILabel!
    @IBOutlet var greaterThanTenVacationDaysLabel: UILabel!
    @IBOutlet var greaterThanFiveVacationDaysLabel: UILabel!
    @IBOutlet var greaterThanZeroVacationDaysLabel: UILabel!
    @IBOutlet var zeroVacationDaysLabel: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
}

//MARK: - Internal
extension DepartmentDetailsViewController {
    func configureView() {
        guard let department = department else { return }
        
        title = department
        
        totalEmployeesLabel.text = totalEmployees(department)
        activeEmployeesLabel.text = activeEmployees(department)
        greaterThanFifteenVacationDaysLabel.text = greaterThanVacationDays(15, department: department)
        greaterThanTenVacationDaysLabel.text = greaterThanVacationDays(10, department: department)
        greaterThanFiveVacationDaysLabel.text = greaterThanVacationDays(5, department: department)
        greaterThanZeroVacationDaysLabel.text = greaterThanVacationDays(0, department: department)
        zeroVacationDaysLabel.text = zeroVacationDays(department)
    }
    
    func totalEmployees(_ department: String) -> String {
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        fetchRequest.predicate = NSPredicate(format: "department == %@", department)
        
        do {
            let results = try coreDataStack.mainContext.fetch(fetchRequest)
            
            return String(results.count)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return "0"
        }
    }
    
    func activeEmployees(_ department: String) -> String {
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        fetchRequest.predicate = NSPredicate(format: "(department == %@) AND (active == YES)", department)
        
        do {
            let results = try coreDataStack.mainContext.fetch(fetchRequest)
            
            return String(results.count)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return "0"
        }
    }
    
    func greaterThanVacationDays(_ vacationDays: Int, department: String) -> String {
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        fetchRequest.predicate = NSPredicate(format: "(department == %@) AND (vacationDays > %i)", department, vacationDays)
        
        do {
            let results = try coreDataStack.mainContext.fetch(fetchRequest)
            return String(results.count)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return "0"
        }
    }
    
    func zeroVacationDays(_ department: String) -> String {
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        fetchRequest.predicate = NSPredicate(format: "(department == %@) AND (vacationDays == 0)", department)

        do {
            let results = try coreDataStack.mainContext.fetch(fetchRequest)
            return String(results.count)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            return "0"
        }
    }
}






















