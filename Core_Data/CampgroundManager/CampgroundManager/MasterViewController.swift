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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
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

class MasterViewController: UITableViewController {

  // MARK: Properties
  var detailViewController: DetailViewController?
  var managedObjectContext: NSManagedObjectContext?
  var _fetchedResultsController: NSFetchedResultsController<CampSite>?

  // MARK: View Life Cycle
  override func awakeFromNib() {
    super.awakeFromNib()

    clearsSelectionOnViewWillAppear = false
    preferredContentSize = CGSize(width: 320.0, height: 600.0)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = editButtonItem

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton

    guard let controllers = splitViewController?.viewControllers,
      let navigationController = controllers.last as? UINavigationController,
      let detailViewController = navigationController.topViewController as? DetailViewController else {
        return
    }

    self.detailViewController = detailViewController
  }

  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    if segue.identifier == "showDetail" {
      guard let indexPath = tableView.indexPathForSelectedRow,
        let navigationController = segue.destination as? UINavigationController,
        let controller = navigationController.topViewController as? DetailViewController else {
          return
      }

      let object = fetchedResultsController.object(at: indexPath)
      controller.detailItem = object
      controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
      controller.navigationItem.leftItemsSupplementBackButton = true
    }
  }
}

// MARK: Internal
extension MasterViewController {

  @objc func insertNewObject(_ sender: Any) {
    let context = fetchedResultsController.managedObjectContext
    let newCampSite = CampSite(context: context)
    newCampSite.siteNumber = 1

    // Save the context.
    do {
      try context.save()
    } catch let error as NSError {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
  }
}

// MARK: UITableViewDataSource
extension MasterViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections!.count
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let campSite = fetchedResultsController.object(at: indexPath)
    configureCell(cell, withCampSite: campSite)
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard case(.delete) = editingStyle else { return }

    let context = fetchedResultsController.managedObjectContext
    context.delete(fetchedResultsController.object(at: indexPath))

    do {
      try context.save()
    } catch let error as NSError {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }
  }
}

// MARK: Private
private extension MasterViewController {

  func configureCell(_ cell: UITableViewCell, withCampSite campSite: CampSite?) {
    guard let campSite = campSite,
      let siteNumber = campSite.siteNumber else {
        return
    }

    cell.textLabel?.text = String(describing: siteNumber)
  }
}

// MARK: NSFetchedResultsControllerDelegate
extension MasterViewController: NSFetchedResultsControllerDelegate {

  var fetchedResultsController: NSFetchedResultsController<CampSite> {
    if _fetchedResultsController != nil {
      return _fetchedResultsController!
    }

    let fetchRequest: NSFetchRequest<CampSite> = CampSite.fetchRequest()
    
    // Set the batch size to a suitable number.
    fetchRequest.fetchBatchSize = 20

    // Edit the sort key as appropriate.
    let sortDescriptor = NSSortDescriptor(key: #keyPath(CampSite.siteNumber), ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
    aFetchedResultsController.delegate = self
    _fetchedResultsController = aFetchedResultsController

    do {
      try _fetchedResultsController!.performFetch()
    } catch let error as NSError {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      fatalError("Unresolved error \(error), \(error.userInfo)")
    }

    return _fetchedResultsController!
  }
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    default:
      return
    }
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
      configureCell(tableView.cellForRow(at: indexPath!)!, withCampSite: anObject as? CampSite)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }

  /*
  // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    // In the simplest, most efficient, case, reload the table view.
    tableView.reloadData()
  }
  */
}

//기본적으로 스위프트의 엑세스 레벨은 internal : 자신의 모듈 내에서만 엑서스할 수 있다.
//앱과 테스트는 별도의 타겟과 개별 모듈이기 때문에 일반적으로 테스트에서 앱 클래스에 접근할 수 없다. 해결방법으로는 3가지가 있다.
//1. 앱의 클래스와 메서드의 엑세스 레벨을 public으로 설정한다. - 테스트에서 접근할 수 있다.
//2. File Inspector에서 테스트의 대상에 클래스를 추가한다.
//3. @testable 키워드를 사용해 테스트에서 import한 클래스의 모든 항목에 접근할 수 있다. //가장 쉬운 방법이지만 이론상으론 1번.
//이 앱에선 테스트에 필요한 클래스와 메서드는 모두 public, open으로 선언되어 있다.

//좋은 테스트를 위한 FIRST
//Fast : 테스트를 실행하는 데 시간이 오래 걸리지 않아야 한다.
//Isolated : 테스트가 자체적으로 실행되거나 다른 테스트 전후에 제대로 작동해야 한다.
//Repeatable : 동일한 코드에 대해 테스트를 실행할 때, 같은 결과를 얻어야 한다.
//Self-verifying : 테스트는 파일이나 콘솔의 로그에서가 아닌 자체적으로 결과(성공 혹은 실패)를 보고해야 한다.
//Timely : 시기 적절성. 테스트가 개발 중에 먼저 작성되어야 한다.
