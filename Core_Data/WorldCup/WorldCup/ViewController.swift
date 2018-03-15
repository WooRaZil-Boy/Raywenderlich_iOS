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

class ViewController: UIViewController {

  // MARK: - Properties
  fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
  var coreDataStack: CoreDataStack!
  lazy var fetchedResultsController: NSFetchedResultsController<Team> = {
    //NSFetchedResultsController로 좀 더 쉽게 tableView와 CoreData를 연결할 수 있다.
    //NSFetchedResultsController는 NSFetchRequest의 결과를 둘러싼 래퍼이다. //실제 Controller가 아니다.
    //NSFetchRequest와 마찬가지로 제네릭 매개변수 엔티티가 필요하다. //항상 데이터와 동기화 된다.
    //크게 1. 세션 //2. 캐싱 //3. 모니터링 의 이점이 있다.
    let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
    //NSFetchRequest가 여전히 칠요하다. 엔티티의 NSFetchRequest를 가져온다. //필터링 없이 모든 Team을 가져온다.
    let zoneSort = NSSortDescriptor(key: #keyPath(Team.qualifyingZone), ascending: true)
    let scoreSort = NSSortDescriptor(key: #keyPath(Team.wins), ascending: false)
    let nameSort = NSSortDescriptor(key: #keyPath(Team.teamName), ascending: true)
    fetchRequest.sortDescriptors = [zoneSort, scoreSort, nameSort]
    //일반적인 NSFetchRequest에서는 정렬를 지정해줄 필요 없다(default로 모든 값을 가져온다).
    //하지만, NSFetchedResultsController는 테이블 뷰에 표현해야 하므로 반드시 하나 이상의 정렬을 지정해 줘야 한다.
    //배열에 넣은 순서대로 정렬한다. zone으로 먼저 정렬 후, score, 이후 name으로 정렬
    //NSFetchedResultsController이 아닌 NSFetchRequest로 배열을 받아와 작업할 경우에는 훨씬 복잡해 진다.
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.managedContext, sectionNameKeyPath: #keyPath(Team.qualifyingZone), cacheName: "worldCup")
    //NSFetchedResultsController를 생성한다.
    //sectionNameKeyPath를 설정하면 해당 키 값으로 세션을 나눌 수 있다(문자열이어야 한다).
    //cacheName로 캐시 이름을 지정하면 캐시를 사용한다. //엔티티가 달라지거나, 정렬 방법 등이 바뀐다면, 다른 캐시를 제공한다.
    //따라서 이런 경우에는 deleteCache(withName :)로 이전 캐시를 삭제하거나 다른 캐시 이름을 사용해야 한다.
    //테이블 뷰는 모든 세션의 정보를 가져온 후에야, 내용을 채울 수 있다. 따라서 세션이 여러개 존재하면 백그라운드에서 작업하더라도,
    //세션 정보를 모두 불러올 때까지 빈 화면을 보여주거나 spinner가 돌아가게 된다. 따라서 많은 데이터가 있을 경우에는 속도가 느려진다.
    //이런 경우 캐쉬를 사용해서 속도를 높일 수 있다.
    fetchedResultsController.delegate = self
    //delegate를 사용해서 모니터링 할 수 있다. 이를 사용하면 효율적으로 뷰와 CoreData를 업데이트 할 수 있다.
    //fetchedResultsController는 생성 시에 연결된 context의 모니터링만 할 수 있다.
    
    return fetchedResultsController
  }()

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addButton: UIBarButtonItem!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try fetchedResultsController.performFetch() //fetch를 실행한다.
      //NSFetchRequest를 이용한 fetch에서는 배열을 반환하지만, NSFetchedResultsController에서는 반환값이 없다.
      //NSFetchedResultsController에서 performFetch()를 실행하면 알아서 래핑된 객체로 반환값을 넣는다.
    } catch let error as NSError {
      print("Fetching error: \(error), \(error.userInfo)")
    }
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake { //흔들었을 때 //시뮬레이터에서 Command + Control + Z
      addButton.isEnabled = true
    }
  }
}

// MARK: - Internal
extension ViewController {

  func configure(cell: UITableViewCell, for indexPath: IndexPath) {

    guard let cell = cell as? TeamCell else {
      return
    }
    
    let team = fetchedResultsController.object(at: indexPath)
    //해당 indexPath에 해당하는 managed object를 가져온다.
    cell.teamLabel.text = team.teamName
    cell.scoreLabel.text = "Wins: \(team.wins)"
    
    if let imageName = team.imageName {
      cell.flagImageView.image = UIImage(named: imageName)
    } else {
      cell.flagImageView.image = nil
    }
  }
}

// MARK: - IBActions
extension ViewController {
  @IBAction func addTeam(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Secret Team", message: "Add a new team", preferredStyle: .alert)
    
    alert.addTextField { textField in
      textField.placeholder = "Team Name"
    } //alert에 텍스트 필드 추가
    
    alert.addTextField { textField in
      textField.placeholder = "Qualifying Zone"
    } //alert에 텍스트 필드 추가
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
      guard let nameTextField = alert.textFields?.first, let zoneTextField = alert.textFields?.last else {
        //추가한 순서대로 textFields배열에 쌓인다.
        return
      }
      
      let team = Team(context: self.coreDataStack.managedContext) //Team managed object 생성
      team.teamName = nameTextField.text
      team.qualifyingZone = zoneTextField.text
      team.imageName = "wenderland-flag"
      
      self.coreDataStack.saveContext() //저장
    }
    
    alert.addAction(saveAction)
    alert.addAction(UIAlertAction(title: "Cancel", style: .default))
    
    present(alert, animated: true)
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = fetchedResultsController.sections else {
      return 0
    }
    
    return sections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let sectionInfo = fetchedResultsController.sections?[section] else {
      //fetchedResultsController.sections에 인덱스로 접근할 수 있다.
      //반환형은 NSFetchedResultsSectionInfo
      return 0
    }
    
    return sectionInfo.numberOfObjects //NSFetchedResultsSectionInfo에서 count 반환
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath)
    configure(cell: cell, for: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let sectionInfo = fetchedResultsController.sections?[section]
    //서브 스크립트로 해당 세션 정보를 가져올 수 있다.
    
    return sectionInfo?.name
  }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let team = fetchedResultsController.object(at: indexPath)
    //해당 indexPath에 해당하는 managed object를 가져온다.
    team.wins = team.wins + 1
    
    coreDataStack.saveContext() //저장
    //NSFetchedResultsController를 생성할 때, coreDataStack을 이용했기 때문에 동일하게 관리된다.
    
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates() //endUpdates()와 함께 쓰여 셀을 다시 로드하지 않고 변경사항을 적용할 수 있다.
    //일련의 메서드를 호출해 동시에 실행되는 애니메이션으로 만들 수 있다.
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    //NSFetchedResultsController 내의 객체 변경되었을 때 알림
    //indexPath : 변경된 객체 //newIndexPath : 변경될 객체
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
    case .update:
      let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
      configure(cell: cell, for: indexPath!)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .automatic)
      tableView.insertRows(at: [newIndexPath!], with: .automatic)
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) { //NSFetchedResultsController에 변경이 있을 때 알림
    tableView.endUpdates() //beginUpdates()와 함께 쓰인다.
    //tableView(_: didSelectRow:)에서 구현하는 것과 비슷하지만 소스에 관계없이 테이블 뷰를 리로드 한다.
  } //이렇게 구현해 높으면, 업데이트 될 때 마다 순서도 제대로 정렬되어 자연스레 애니메이션 된다.
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    //위의 메서드와 비슷하지만, 세션의 변경 사항을 알려준다.
    let indexSet = IndexSet(integer: sectionIndex) //[indexPath] 처럼, indexSet
    
    switch type {
    case .insert:
      tableView.insertSections(indexSet, with: .automatic)
    case .delete:
      tableView.deleteSections(indexSet, with: .automatic)
    default: break
    }
  }
}
