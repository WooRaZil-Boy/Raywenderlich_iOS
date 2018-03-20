/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreData

class DepartmentListViewController: UITableViewController {

  // MARK: Properties
  var coreDataStack: CoreDataStack!
  var items: [[String: String]] = []

  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

//    items = totalEmployeesPerDepartment()
    items = totalEmployeesPerDepartmentFast()
  }

  // MARK: Navigation
  override func prepare(
    for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == "SegueDepartmentListToDepartmentDetails" {

      guard let tableViewCell = sender as? UITableViewCell,
        let indexPath = tableView.indexPath(for: tableViewCell),
        let controller = segue.destination
          as? DepartmentDetailsViewController else {
            return
      }

      let departmentDictionary = items[indexPath.row]
      let department = departmentDictionary["department"]

      controller.coreDataStack = coreDataStack
      controller.department = department

    } else if segue.identifier == "SegueDepartmentsListToEmployeeList" {

      guard let indexPath = tableView.indexPathForSelectedRow,
        let controller = segue.destination
          as? EmployeeListViewController else {
            return
      }

      let departmentDictionary = items[indexPath.row]
      let department = departmentDictionary["department"]

      controller.coreDataStack = coreDataStack
      controller.department = department
    }
  }
}

// MARK: Internal
extension DepartmentListViewController {

  func totalEmployeesPerDepartment() -> [[String: String]] {

    //1 //필터 없이 모든 데이터 가져온다.
    let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
    //fetch Request 가져오기.

    var fetchResults: [Employee] = []
    do {
      fetchResults = try coreDataStack.mainContext.fetch(fetchRequest)
    } catch let error as NSError {
      print("ERROR: \(error.localizedDescription)")
      return [[String: String]]()
    }

    //2 //fetch 된 결과에서 딕셔너리로 분류한다.
    var uniqueDepartments: [String: Int] = [:]
    for employee in fetchResults {
      
      if let employeeDepartmentCount = uniqueDepartments[employee.department!] {
        uniqueDepartments[employee.department!] = employeeDepartmentCount + 1
      } else {
        uniqueDepartments[employee.department!] = 1
      }
    }

    //3 //분류된 딕셔너리에서 필요한 정보를 가져와 배열로 만든다.
    var results: [[String: String]] = []
    for (department, headCount) in uniqueDepartments {

      let departmentDictionary: [String: String] =
        ["department": department,
         "headCount": String(headCount)]

      results.append(departmentDictionary)
    }

    return results
  }
  //이 구현은 Department만 가져오면 되는 쿼리인데, 쓸데 없이 여러 데이터를 가져오기 때문에 리소스가 낭비된다.
  
  func totalEmployeesPerDepartmentFast() -> [[String: String]] {
    let expressionDescription = NSExpressionDescription()
    //fetch request와 함께 사용하는 특수 속성 Description
    expressionDescription.name = "headCount" //이름을 지정해 준다. 딕셔너리에서 키 값으로 쓰인다.
    expressionDescription.expression = NSExpression(forFunction: "count:", arguments: [NSExpression(forKeyPath: "department")]) //표현식 생성
    
    let fetchRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Employee")
    //해당 Entity로 fetch 요청
    fetchRequest.propertiesToFetch = ["department", expressionDescription]
    //fetch에서 가져올 속성을 지정한다. //가져올 속성과 속성의 필터링 옵션
    fetchRequest.propertiesToGroupBy = ["department"] //SQL에서의 GroupBy
    //부서 속성별로 그룹화(부서 별로 따로 카운팅 된다)
    fetchRequest.resultType = .dictionaryResultType //반환 유형 dictionary
    
    var fetchResults: [NSDictionary] = []
    do {
      fetchResults = try coreDataStack.mainContext.fetch(fetchRequest) //fetch 실행
    } catch let error as NSError {
      print("ERROR: \(error.localizedDescription)")
      return [[String: String]]()
    }
    
    return fetchResults as! [[String: String]]
  }
  //필터링 해 가져오는 데이터를 줄인다. //apple.co/2a1Rq2n
  //NSExpression은 사용하는 경우가 사실 많이 없다(어려움). 보통 fetch predication으로 필터링 하는 경우 많다.
  //XCTest로 테스트 해 성능을 개선한다.
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
