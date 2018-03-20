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

class EmployeeListViewController: UITableViewController {

  // MARK: Properties
  var coreDataStack: CoreDataStack!

  var fetchedResultController: NSFetchedResultsController<Employee> = NSFetchedResultsController()

  var department: String?

  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
  }

  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    guard segue.identifier == "SegueEmployeeListToDetail",
      let indexPath = tableView.indexPathForSelectedRow,
      let controller = segue.destination
        as? EmployeeDetailViewController else {
        return
    }

    let selectedEmployee =
      fetchedResultController.object(at: indexPath)
    controller.employee = selectedEmployee
  }
}

// MARK: Private
private extension EmployeeListViewController {

  func configureView() {
    fetchedResultController = employeesFetchedResultControllerFor(department)
  }
}
  
// MARK: NSFetchedResultsController
extension EmployeeListViewController {

  func employeesFetchedResultControllerFor(_ department: String?) -> NSFetchedResultsController<Employee> {

    fetchedResultController = NSFetchedResultsController(
      fetchRequest: employeeFetchRequest(department),
      managedObjectContext: coreDataStack.mainContext,
      sectionNameKeyPath: nil,
      cacheName: nil)

    fetchedResultController.delegate = self

    do {
      try fetchedResultController.performFetch()
      return fetchedResultController
    } catch let error as NSError {
      fatalError("Error: \(error.localizedDescription)")
    }
  }

  func employeeFetchRequest(_ department: String?) -> NSFetchRequest<Employee> {

    let fetchRequest: NSFetchRequest<Employee> = Employee.fetchRequest()
    fetchRequest.fetchBatchSize = 10
    //CoreData fetch request에는 fetchBatchSize가 있어 적절한 만큼의 양만을 가져오게 할 수 있다.
    //따로 fetchBatchSize를 설정하지 않았다면 default로 0이 되어 이 기능비 비활성화된다.
    //fetchBatchSize는 화면에 표시되는 항목의 두 배 정도로 설정하는 것이 일반적이다.
    //Instruments에서 확인해 보면 해당 기능을 활성화하면 속도가 2배 이상 빨라진다.

    let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]

    guard let department = department else {
      return fetchRequest
    }

    fetchRequest.predicate = NSPredicate(format: "department == %@", department)

    return fetchRequest
  }
}

// MARK: NSFetchedResultsControllerDelegate
extension EmployeeListViewController: NSFetchedResultsControllerDelegate {

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension EmployeeListViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultController.sections!.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultController.sections![section].numberOfObjects
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let reuseIdentifier = "EmployeeCellReuseIdentifier"

    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                             for: indexPath) as! EmployeeTableViewCell

    let employee = fetchedResultController.object(at: indexPath)

    cell.nameLabel.text = employee.name
    cell.departmentLabel.text = employee.department
    cell.emailLabel.text = employee.email
    cell.phoneNumberLabel.text = employee.phone
    cell.pictureImageView.image = UIImage(data: employee.pictureThumbnail!)
    //원본 데이터 모델에는 프로필 사진이 blob으로 저장되어 있다. 따라서 CoreData에 직원 이름이나 메일 주소에만 접근하려 해도
    //직원 데이터에 엑세스해야 하는데, 이 때마다 사진을 로드하므로 메모리 사용량이 늘어나게 된다.
    //이진 데이터는 일반적으로 DB에 바로 저장된다.
    //외부 저장소 허용하면 별도의 파일로 디스크에 저장할지, SQLite DB에 저장할지 OS가 알아서 판단한다.
    //직원 데이터를 가져올 때 썸네일 이미지만 불러오고, Detail 보기가 필요할 때 원본 이미지 데이터를 가져오는 식으로 메모리를 줄인다.
    //원본 이미지 엔티티를 새로 생성하고, relationship으로 연결한다.
    //삭제 규칙을 Cascade로 지정하면, parent가 삭제되면 children도 삭제된다.

    return cell
  }
}

//CoreData 객체는 RAM(메모리) 혹은 디스크에 위치할 수 있다. RAM이 훨씬 빠르지만, 공간이 제한되어 있다.
//개발을 Measure - Change - Verify의 단계로 반복한다.
//Measure : Gauges, Instruments, XCTest 등을 사용하여 성능을 측정한다.
//Change : 성능을 향상시키도록 코드를 변경한다.
//Verify : 의도대로 결과가 변경되었는지 확인한다.

//Debug navigator 탭에서 메모리 사용량을 그래프로 볼 수 있다.

//Instruments 툴을 사용해, fetch 작업을 분석할 수 있다. (⌘I) 시뮬레이터에서만 이 기능을 사용할 수 있다.
//Instruments에는 다음과 같은 모니터링 도구가 있다.
//Fetches Instrument : fetch 횟수 및 fetch 작업 지속 시간. fetch 요청 수와 각 요청의 사이즈
//Cache Misses Instrument : 캐시 실패하게 하는 오류에 대한 정보
//Saves Instrument : managed object context에 대한 정보

//Instruments에서 fetch에 걸린 시간과 count를 찾을 수 있다.
