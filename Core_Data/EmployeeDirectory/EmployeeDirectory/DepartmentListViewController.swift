//
//  DepartmentListViewController.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class DepartmentListViewController: UITableViewController {
    //MARK: - Properties
    var coreDataStack: CoreDataStack!
    var items: [[String: String]] = []
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = totalEmployeesPerDepartmentFast()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueDepartmentListToDepartmentDetails" {
            guard let tableViewCell = sender as? UITableViewCell,
                  let indexPath = tableView.indexPath(for: tableViewCell),
                  let controller = segue.destination as? DepartmentDetailsViewController else {
                    return
            }
            
            let departmentDictionary = items[indexPath.row]
            let department = departmentDictionary["department"]
            
            controller.coreDataStack = coreDataStack
            controller.department = department
        } else if segue.identifier == "SegueDepartmentsListToEmployeeList" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let controller = segue.destination as? EmployeeListViewController else {
                    return
            }
            
            let departmentDictionary = items[indexPath.row]
            let department = departmentDictionary["department"]
            
            controller.coreDataStack = coreDataStack
            controller.department = department
        }
    }
}

// MARK: - Internal
extension DepartmentListViewController {
    func totalEmployeesPerDepartment() -> [[String: String]] { //예전 메서드
        //1
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        
        var fetchResults: [Employee] = []
        do {
            fetchResults = try coreDataStack.mainContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("ERROR: \(error.localizedDescription)")
            return [[String: String]]()
        }
        
        //2
        var uniqueDepartments: [String: Int] = [:]
        for employee in fetchResults {
            if let employeeDepartmentCount = uniqueDepartments[employee.department] {
                uniqueDepartments[employee.department] = employeeDepartmentCount + 1
            } else {
                uniqueDepartments[employee.department] = 1
            }
        }
        
        //3
        var results: [[String: String]] = []
        for (department, headCount) in uniqueDepartments {
            let departmentDictionary: [String: String] =
                ["department": department,
                 "headCount": String(headCount)]
            
            results.append(departmentDictionary)
        }
        
        return results
    }
    
    func totalEmployeesPerDepartmentFast() -> [[String: String]]  {
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "headCount"
        expressionDescription.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "department")]) //NSExpression 표현식은 대 부분 평균, 합계 최소, 최대 등 미리 만들어진 다른 메서드들이 있어 자주 사용되지는 않는다.
        
        let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Employee") //let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee") 이렇게 하면 전체 직원을 로드 해 온다. 여기서는 특정 부서의 직원만 필요하므로 메모리 낭비
        fetchRequest.propertiesToFetch = ["department", expressionDescription]
        fetchRequest.propertiesToGroupBy = ["department"]
        fetchRequest.resultType = .dictionaryResultType //딕셔너리로 반환
        
        var fetchResults: [NSDictionary] = []
        do {
            fetchResults = try coreDataStack.mainContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("ERROR: \(error.localizedDescription)")
            return [[String: String]]()
        }
        
        return fetchResults as! [[String: String]]
    }
}

// MARK: UITableViewDataSource
extension DepartmentListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let departmentDictionary: [String: String] = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "DepartmentCellReuseIdentifier",
                                                 for: indexPath)
        
        cell.textLabel?.text = departmentDictionary["department"]
        cell.detailTextLabel?.text = departmentDictionary["headCount"]
        
        return cell
    }
}

































