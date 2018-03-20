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

class EmployeeDetailViewController: UIViewController {

  // MARK: - Properties
  fileprivate lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter
  }()

  var employee: Employee?

  // MARK: IBOutlets
  @IBOutlet var headShotImageView: UIImageView!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var departmentLabel: UILabel!
  @IBOutlet var emailLabel: UILabel!
  @IBOutlet var phoneNumberLabel: UILabel!
  @IBOutlet var startDateLabel: UILabel!
  @IBOutlet var vacationDaysLabel: UILabel!
  @IBOutlet var salesCountLabel: UILabel!
  @IBOutlet var bioTextView: UITextView!

  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
  }

  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    guard segue.identifier == "SegueEmployeeDetailToEmployeePicture",
      let controller = segue.destination
        as? EmployeePictureViewController else {
          return
    }

    controller.employee = employee
  }
}

// MARK: Private
private extension EmployeeDetailViewController {

  func configureView() {
    guard let employee = employee else { return }

    title = employee.name
    
    let image = UIImage(data: employee.pictureThumbnail!) //전체 이미지 아닌 썸네일 이미지면 충분하다.
    headShotImageView.image = image

    nameLabel.text = employee.name
    departmentLabel.text = employee.department
    emailLabel.text = employee.email
    phoneNumberLabel.text = employee.phone

    startDateLabel.text = dateFormatter.string(from: employee.startDate!)

    vacationDaysLabel.text = String(describing: employee.vacationDays?.intValue)

    bioTextView.text = employee.about

//    salesCountLabel.text = salesCountForEmployee(employee)
//    salesCountLabel.text = salesCountForEmployeeFast(employee)
    salesCountLabel.text = salesCountForEmployeeSimple(employee)
  }
}

// MARK: Internal
extension EmployeeDetailViewController {

  func salesCountForEmployee(_ employee: Employee) -> String {
    
    let fetchRequest: NSFetchRequest<Sale> = Sale.fetchRequest()
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Sale.employee), employee)
    fetchRequest.predicate = predicate

    let context = employee.managedObjectContext!
    do {
      let results = try context.fetch(fetchRequest)
      return "\(results.count)"
    } catch let error as NSError {
      print("Error: \(error.localizedDescription)")
      return "0"
    }
  }
  //직원의 모든 판매를 가져온 다음 카운트 해서 메모리가 낭비된다.
  
  func salesCountForEmployeeFast(_ employee: Employee) -> String {
    let fetchRequest: NSFetchRequest<Sale> = Sale.fetchRequest()
    let predicate = NSPredicate(format: "%K == %@", #keyPath(Sale.employee), employee)
    fetchRequest.predicate = predicate
    
    let context = employee.managedObjectContext!
    
    do {
      let results = try context.count(for: fetchRequest) //fetch 대신 count를 실행한다.
      return "\(results)"
    } catch let error as NSError {
      print("Error: \(error.localizedDescription)")
      return "0"
    }
  }
  
  func salesCountForEmployeeSimple(_ employee: Employee) -> String {
    //성능은 개선되었지만, fetch, description 작성, context 참조, fetch 실행, 결과 정렬 등 과정이 복잡하다.
    //employee의 sales 속성을 사용해서 간단히 구현
    return "\(employee.sales!.count)"
  }
  //성능은 salesCountForEmployeeFast(_ :)이 더 빠르지만, 거의 차이가 없고 코드를 직관적으로 이해할 수 있다.
}
