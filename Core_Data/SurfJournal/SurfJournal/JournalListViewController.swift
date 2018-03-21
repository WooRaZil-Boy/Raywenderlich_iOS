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

class JournalListViewController: UITableViewController {

  // MARK: Properties
  var coreDataStack: CoreDataStack!
  var fetchedResultsController: NSFetchedResultsController<JournalEntry> = NSFetchedResultsController()

  // MARK: IBOutlets
  @IBOutlet weak var exportButton: UIBarButtonItem!

  // MARK: View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    configureView()
  }

  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // 1
    if segue.identifier == "SegueListToDetail" { //테이블 셀을 터치할 때 세부 사항 출력
      // 2
      guard let navigationController = segue.destination as? UINavigationController,
        let detailViewController = navigationController.topViewController as? JournalEntryViewController,
        let indexPath = tableView.indexPathForSelectedRow else {
          fatalError("Application storyboard mis-configuration")
      }
      // 3
      let surfJournalEntry = fetchedResultsController.object(at: indexPath)
      // 4
      let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
      //현재 큐에 새로운 관리 컨텍스트 생성
      //persistent store coordinator > main context > child context로 모델을 짤 수 있다.
      //최상위 저장소는 persistent store coordinator로 CoreDataStack에 있는 main context이다.
      //하위 컨텍스트를 변경하면 그 내용은 상위 컨텍스트로 이동한다. 상위 컨텍스트가 변경 될 때까지
      //상위 컨텍스트의 변경 내용은 persistent store coordinator로 보내지지 않는다.
      childContext.parent = coreDataStack.mainContext //부모 컨텍스트 설정
      
      let childEntry = childContext.object(with: surfJournalEntry.objectID) as? JournalEntry
      //해당 managed object 검색 //objectID는 여러 컨텍스트에서 해당 객체에 접근할 때도 쓸 수 있다.
      detailViewController.journalEntry = childEntry
      detailViewController.context = childContext
      //managed object의 객체가 컨텍스트에 대한 weak 참조만 가지고 있기 때문에 컨텍스트를 전달하지 않으면
      //ARC에 의해 제거될 수 있다.
      detailViewController.delegate = self
      
      //이런식으로 컨텍스트를 분할하면 앱의 복잡성을 줄일 수 있다.
      //별도의 컨텍스트에서 편집을 하면, managed object의 변경 내용을 취소하거나 저장하는 것이 간편해 진다.
      
//      detailViewController.journalEntry = surfJournalEntry
//      detailViewController.context = surfJournalEntry.managedObjectContext
//      detailViewController.delegate = self

    } else if segue.identifier == "SegueListToDetailAdd" { //리스트를 추가할 때

      guard let navigationController = segue.destination as? UINavigationController,
        let detailViewController = navigationController.topViewController as? JournalEntryViewController else {
          fatalError("Application storyboard mis-configuration")
      }

      let newJournalEntry = JournalEntry(context: coreDataStack.mainContext)

      detailViewController.journalEntry = newJournalEntry
      detailViewController.context = newJournalEntry.managedObjectContext
      detailViewController.delegate = self
    }
  }
}

// MARK: IBActions
extension JournalListViewController {

  @IBAction func exportButtonTapped(_ sender: UIBarButtonItem) {
    exportCSVFile()
  }
}

// MARK: Private
private extension JournalListViewController {

  func configureView() {
    fetchedResultsController = journalListFetchedResultsController()
  }

  func exportCSVFile() {
    navigationItem.leftBarButtonItem = activityIndicatorBarButtonItem()
    
    // 1
    //UI를 차단하는 작업은 GCD를 사용해여 백그라운드에서 작업하도록 할 수 있지만,
    //CoreData managed object는 non-thread-safe이다.
    //(백그라운드로 보내면 동일한 CoreData stack을 사용할 수 없다)
    //이를 main queue가 아닌 해당 작업을 위한 private queue를 생성해서 해결할 수 있다.
    coreDataStack.storeContainer.performBackgroundTask { context in
      //NSPersistentContainer가 concurrencyType이 privateQueueConcurrencyType으로 설정된
      //새 NSManagedObjectContext를 만든다. 그 후, 전달 된 블록을 컨텍스트의
      //private queue에 새로 생성 된 컨텍스트에 대해 실행한다.
      //여기서 생성된 컨텍스트는 메인 큐를 차단하지 않는 private queue에서 작동된다.
      //.privateQueueConcurrencyType 타입의 새로운 임시 컨텍스트를 수동으로 생성할 수도 있다.
      
      //Queue는 두 가지 유형이 있다.
      //Private Queue : UI 작업을 방해하지 않는다. 개별 적인 큐
      //Main Queue : 기본 컨텍스트(coreDataStack.mainContext)가 사용하는 유형. UI 작업은 여기서 이뤄져야 한다.
      var results: [JournalEntry] = []
      do {
        results = try context.fetch(self.surfJournalFetchRequest()) //모든 JournalEntry 가져오기
      } catch let error as NSError {
        print("ERROR: \(error.localizedDescription)")
      }
  
      // 2
      let exportFilePath = NSTemporaryDirectory() + "export.csv" //저장할 경로
      //NSTemporaryDirectory : 현재 사용자의 임시 디렉토리 경로 반환
      let exportFileURL = URL(fileURLWithPath: exportFilePath) //url 생성
      FileManager.default.createFile(atPath: exportFilePath, contents: Data(), attributes: nil)
      //해당 경로에 빈 파일을 만든다. //Data() : 빈 파일

      // 3
      let fileHandle: FileHandle? //쓰기를 위한 파일 핸들러 //단순 쓰기에 필요한 저수준 디스크 작업 처리
      do {
        fileHandle = try FileHandle(forWritingTo: exportFileURL) //해당 경로로 초기화
      } catch let error as NSError {
        print("ERROR: \(error.localizedDescription)")
        fileHandle = nil
      }

      if let fileHandle = fileHandle { //제대로 생성 되었으면
        // 4
        for journalEntry in results { //불러온 managed object 결과에서 하나씩 반복
          fileHandle.seekToEndOfFile() //파일 포인터를 파일의 끝으로 설정
          guard let csvData = journalEntry
            .csv() //csv로 만든 string
            .data(using: .utf8, allowLossyConversion: false) else {
              //해당 인코딩 사용해 Data로 반환
              continue
          }

          fileHandle.write(csvData) //Data 쓰기
        }

        // 5
        fileHandle.closeFile() //더 이상 필요하지 않으면 파일 핸들러를 닫는다.

        print("Export Path: \(exportFilePath)")
        //6
        DispatchQueue.main.async { //UI업데이트는 메인 큐에서 진행되어야 한다.
          self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
          self.showExportFinishedAlertView(exportFilePath)
        }
      } else {
        DispatchQueue.main.async { //UI업데이트는 메인 큐에서 진행되어야 한다.
          self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
        }
      }
    }
  }// 7 Closing brace for performBackgroundTask

  // MARK: Export
  
  func activityIndicatorBarButtonItem() -> UIBarButtonItem {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let barButtonItem = UIBarButtonItem(customView: activityIndicator)
    activityIndicator.startAnimating()
    
    return barButtonItem
  }
  
  func exportBarButtonItem() -> UIBarButtonItem {
    return UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportButtonTapped(_:)))
  }

  func showExportFinishedAlertView(_ exportPath: String) {
    let message = "The exported CSV file can be found at \(exportPath)"
    let alertController = UIAlertController(title: "Export Finished", message: message, preferredStyle: .alert)
    let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
    alertController.addAction(dismissAction)

    present(alertController, animated: true)
  }
}

// MARK: NSFetchedResultsController
private extension JournalListViewController {

  func journalListFetchedResultsController() -> NSFetchedResultsController<JournalEntry> {
    let fetchedResultController = NSFetchedResultsController(fetchRequest: surfJournalFetchRequest(),
                                                             managedObjectContext: coreDataStack.mainContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
    fetchedResultController.delegate = self

    do {
      try fetchedResultController.performFetch()
    } catch let error as NSError {
      fatalError("Error: \(error.localizedDescription)")
    }

    return fetchedResultController
  }

  func surfJournalFetchRequest() -> NSFetchRequest<JournalEntry> {
    let fetchRequest:NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
    fetchRequest.fetchBatchSize = 20

    let sortDescriptor = NSSortDescriptor(key: #keyPath(JournalEntry.date), ascending: false)
    fetchRequest.sortDescriptors = [sortDescriptor]

    return fetchRequest
  }
}

// MARK: NSFetchedResultsControllerDelegate
extension JournalListViewController: NSFetchedResultsControllerDelegate {

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension JournalListViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fetchedResultsController.sections?[section].numberOfObjects ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurfEntryTableViewCell
    configureCell(cell, indexPath: indexPath)
    return cell
  }

  private func configureCell(_ cell: SurfEntryTableViewCell, indexPath:IndexPath) {
    let surfJournalEntry = fetchedResultsController.object(at: indexPath)
    cell.dateLabel.text = surfJournalEntry.stringForDate()

    guard let rating = surfJournalEntry.rating?.int32Value else { return }

    switch rating {
    case 1:
      cell.starOneFilledImageView.isHidden = false
      cell.starTwoFilledImageView.isHidden = true
      cell.starThreeFilledImageView.isHidden = true
      cell.starFourFilledImageView.isHidden = true
      cell.starFiveFilledImageView.isHidden = true
    case 2:
      cell.starOneFilledImageView.isHidden = false
      cell.starTwoFilledImageView.isHidden = false
      cell.starThreeFilledImageView.isHidden = true
      cell.starFourFilledImageView.isHidden = true
      cell.starFiveFilledImageView.isHidden = true
    case 3:
      cell.starOneFilledImageView.isHidden = false
      cell.starTwoFilledImageView.isHidden = false
      cell.starThreeFilledImageView.isHidden = false
      cell.starFourFilledImageView.isHidden = true
      cell.starFiveFilledImageView.isHidden = true
    case 4:
      cell.starOneFilledImageView.isHidden = false
      cell.starTwoFilledImageView.isHidden = false
      cell.starThreeFilledImageView.isHidden = false
      cell.starFourFilledImageView.isHidden = false
      cell.starFiveFilledImageView.isHidden = true
    case 5:
      cell.starOneFilledImageView.isHidden = false
      cell.starTwoFilledImageView.isHidden = false
      cell.starThreeFilledImageView.isHidden = false
      cell.starFourFilledImageView.isHidden = false
      cell.starFiveFilledImageView.isHidden = false
    default :
      cell.starOneFilledImageView.isHidden = true
      cell.starTwoFilledImageView.isHidden = true
      cell.starThreeFilledImageView.isHidden = true
      cell.starFourFilledImageView.isHidden = true
      cell.starFiveFilledImageView.isHidden = true
    }
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard case(.delete) = editingStyle else { return }

    let surfJournalEntry = fetchedResultsController.object(at: indexPath)
    coreDataStack.mainContext.delete(surfJournalEntry)
    coreDataStack.saveContext()
  }
}

// MARK: JournalEntryDelegate
extension JournalListViewController: JournalEntryDelegate {
  
  func didFinish(viewController: JournalEntryViewController, didSave: Bool) {

    guard didSave,
      let context = viewController.context,
      context.hasChanges else {
        //context.hasChanges로 해당 컨텍스트에 변경이 있는지 알 수 있다.
        dismiss(animated: true)
        return
    } //guard로 유요한 변수인지 확인

    context.perform { //비동기적으로 실행
      //delegate에서 해당 뷰의 컨텍스트가 메인인지 자식인지 알 수 없다.
      //따라서 perform 내부에서 사용하는 것이 안전하다.
      do {
        try context.save() //해당 컨텍스트 저장
      } catch let error as NSError {
        fatalError("Error: \(error.localizedDescription)")
      }

      self.coreDataStack.saveContext() //메인 컨텍스트 저장 //메인 컨텍스트의 변경이 있을 경우에만 작동
    }

    dismiss(animated: true)
  }
}

//여러 개의 managed object context를 사용할 수는 있지만, 보통은 단일 객체 컨텍스트를 사용한다.
//컨텍스트가 많을 수록 관리하고 디버그하기 어려워진다.
//하지만 특정 경우(예. 데이터 내보내기 같은 장기간 실행되는 작업은 하나의 main-queue managed object를 사용하면,
//메인 스레드를 차단해 버릴 수 있다.)에 유용하게 쓸 수 있다.
