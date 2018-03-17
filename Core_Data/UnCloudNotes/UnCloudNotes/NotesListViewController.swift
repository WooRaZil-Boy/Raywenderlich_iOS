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

class NotesListViewController: UITableViewController {

  // MARK: - Properties
  fileprivate lazy var stack: CoreDataStack = { //lazy로 stack이 한 번만 초기화 되게 한다.
    let manager = DataMigrationManager(modelNamed: "UnCloudNotesDataModel", enableMigrations: true)
    //실제 초기화는 DataMigrationManager에서 처리된다. 따라서 사용되는 stack은 마이그레이션 관리자에서 반환된 stack.
    
    return manager.stack
  }()

  fileprivate lazy var notes: NSFetchedResultsController<Note> = {
    let context = self.stack.managedContext
    let request = Note.fetchRequest() as! NSFetchRequest<Note>
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.dateCreated), ascending: false)]

    let notes = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    notes.delegate = self
    return notes
  }()

  // MARK: - View Life Cycle
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    do {
      try notes.performFetch()
    } catch {
      print("Error: \(error)")
    }

    tableView.reloadData()
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let navController = segue.destination as? UINavigationController,
      let viewController = navController.topViewController as? UsesCoreDataObjects {
        viewController.managedObjectContext = stack.savingContext
    }

    if let detailView = segue.destination as? NoteDisplayable,
      let selectedIndex = tableView.indexPathForSelectedRow {
        detailView.note = notes.object(at: selectedIndex)
    }
  }
}

// MARK: - IBActions
extension NotesListViewController {

  @IBAction func unwindToNotesList(_ segue: UIStoryboardSegue) {
    print("Unwinding to Notes List")

    stack.saveContext()
  }
}

// MARK: - UITableViewDataSource
extension NotesListViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let objects = notes.fetchedObjects
    return objects?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let note = notes.object(at: indexPath) //notes에서 해당 index의 managed object를 가져온다.
    let cell: NoteTableViewCell
    if note.image == nil { //이미지 없는 경우 (v1 포함)
      cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteTableViewCell
    } else { //이미지 있는 경우
      cell = tableView.dequeueReusableCell(withIdentifier: "NoteCellWithImage", for: indexPath) as! NoteImageTableViewCell
    }
    
    cell.note = note
    return cell
  }
}

// MARK: - NSFetchedResultsControllerDelegate
extension NotesListViewController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    let wrapIndexPath: (IndexPath?) -> [IndexPath] = { $0.map { [$0] } ?? [] }

    switch type {
    case .insert:
      tableView.insertRows(at: wrapIndexPath(newIndexPath), with: .automatic)
    case .delete:
      tableView.deleteRows(at: wrapIndexPath(indexPath), with: .automatic)
    default:
      break
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
  }
}

//CoreData를 사용해, 앱이 출시되어 Data Model이 변경되더라도 마이그레이션할 수 있다.
//이미 사용하던 모델과 호환이 되도록 기능을 변경하고 구현해야 한다.
//CoreData의 모델을 분석해서 이전 모델의 코디네이터 버전이 같지 않으면, CoreData에서 마이그레이션을 진행한다.
//모델이 호환되지 않거나 마이그레이션을 실패하는 경우가 있을 수도 있다.
//원본 Data Model과 새로 만들 Data Model이 필요하다. 이 두 버전을 이용하여 마이그레이션에 대한 Mapping Model을 만든다.
//이 Mapping Model은 원본 데이터를 변환해 새로운 Data Model에 호환이 되도록 한다.
//1. CoreData의 원본 데이터를 복사해 새로운 저장소에 가져온다.
//2. Mapping에 따라 모든 object를 연결하고 종속성을 지정해 준다.
//3. 새로운 Data Model에서 모든 데이터의 유효성 검사를 실행한다.
//마이그레이션이 오류없이 성공하면 원본 저장소를 제거한다. 오류가 있는 경우에는 원본 저장소가 삭제되지 않는다.

//마이그레이션에는 3가지 타입이 있다(공식적인 분류법은 아니다).
//● Lightweight migrations : NSPersistentContainer를 사용할 때 자동으로 설정되거나,
//      CoreData Stack을 빌드할 때 설정한다. 제한적인 마이그레이션을 할 수 있지만, 쉽고 빠르게 마이그레이션 할 수 있다.
//      Model 편집기에서 Add Model Version...으로 실행한다. 이후 새 모델 버전을 사용하도록 Current에서 변경. p.149
//● Manual migrations : 새 Data Model에 Mapping하는 방법을 직접 지정해 줘야 한다.
//• Custom manual migrations : 새 Data Model에 Mappingg하는 방법을 지정하면서
//      NSEntityMigrationPolicy(엔티티를 변환하는 논리 지정)를 상속받아 구현해야 한다.
//• Fully manual migrations : Custom manual migrations이 제대로 작동하지 않을 때 사용한다.

//CoreData는 지정된 현재 버전의 모델에 먼저 연결을 한다. 이후, 그 모델이 현재 데이터와 호환되지 않으면 마이그레이션 된다.
//따라서 이전 모델이라도 호환성 유지와 확장성 측면에서 원본을 가지고 있는 것이 좋다.

//CoreData는 NSPersistentStoreDescription에서 shouldInferMappingModelAutomatically 여부로 매핑 모델 유추한다.
//매핑 모델을 자동으로 만들 수 있는 패턴은 다음 중의 경우에 해당할 때이다.
//• entitiy, attribute, relationship의 삭제
//• entitiy, attribute, relationship의 이름 변경(renamingIdentifier 사용)
//• 새로운 optional attribute 추가
//• default value가 있는 새로운 non-optional attribute 추가
//• optional attribute를 non-optional로 변경 하고 default value 추가
//• non-optional attribute를 optional로 변경
//• entitiy 계층 구조 변경
//• 새로운 상위 entitiy 추가 및 계층 구조 내 attribute의 위치 변경
//• to-one에서 to-many로 relationship 변경
//• non-ordered to-many에서 ordered to-many로 relationship 변경(반대의 경우도 성립)

//모든 마이그레이션은 자동으로 설정되는 Lightweight migrations부터 시작해서 필요한 경우 Custom한 부분을 추가해 주는 것이 좋다.
//모든 마이그레이션의 첫 번째 할 일은 새 모델 버전을 생성하는 것이다.

//매핑 모델을 만들기 전에 새로운 Data Model을 만들고 설정을 마무리 해야 한다.
//매핑 모델 생성 시 원본과 새 Data Model을 고정 시키기 때문에 순서가 바뀌면 안된다.
//Lightweight migrations로 마이그레이션을 완료할 수 없을 경우에는 New\File 에서 Mapping Model을 직접 만들어야 한다. p.160

//매핑 모델의 엔티티 맵핑에서 Filter predicate(image != nil)를 설정해 주면 해당 조건 일 때만 매핑이 일어난다.
//FUNCTION($manager, "destinationInstancesForEntityMappingNamed:sourceInstances:", "NoteToNote", $source)
//relationship을 Mapping하면 위와 같은 FUNCTION문이 삽입 된다.
//첫째 인자는 객체 인스턴스, 둘째 인자는 selector 나머지 인자는 selector에서 사용될 파라미터
//$manager는 마이그레이션을 처리하는 NSMigrationManager에 대한 참조를 만든다.
//destinationInstancesForEntityMappingNamed:sourceInstances: 메서드는 원본 객체의 대상 인스턴스를 조회한다.
//"NoteToNote 매핑에 의해 $source 개체가 마이그레이션되는 모든 것에 대한 설정."
//이렇게 커스텀 하게 매핑한 경우에는 CoreData가 자동으로 모델 유추하지 않도록 설정해 주어야 한다.

