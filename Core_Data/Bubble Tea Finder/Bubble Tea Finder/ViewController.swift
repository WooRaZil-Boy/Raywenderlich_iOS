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
  private let filterViewControllerSegueIdentifier = "toFilterViewController"
  fileprivate let venueCellIdentifier = "VenueCell"

  var coreDataStack: CoreDataStack!
  var fetchRequest: NSFetchRequest<Venue>?
  var venues: [Venue] = []
  
  var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>? //비동기
  //NSFetchRequest는 메인 스레드를 차단해 터치에 반응하지 않고, UI 업데이트도 할 수 없다.
  //iOS 8부터 백그라운드에서 비동기로 fetch하고 클로저로 결과를 받아올 수 있다.
  //NSFetchRequest가 아닌 NSPersistentStoreRequest의 하위 클래스

  // MARK: - IBOutlets
  @IBOutlet weak var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
//    guard let model = coreDataStack.managedContext.persistentStoreCoordinator?.managedObjectModel, let fetchRequest = model.fetchRequestTemplate(forName: "FetchRequest") as? NSFetchRequest<Venue> else {
//      //자주 사용하는 fetch request를 데이터 모델에 바로 저장할 수 있다. p.92
//      //비주얼 편집기에서 추가된 fetchRequest를 사용한다. 이 방법을 사용하면
//      //1. 다른 fetch request와 달리 모델과 관련되어 있으므로 coreDataStack을 통해 가져와야 한다.
//      //2. CoreDataStack에서 managed context만 public이다. 따라서 managed context의 Coordinator를 가져와야 한다.
//      //3. fetchRequestTemplate(forName :)의 파라미터 문자열이 비주얼 모델 편집기에서 설정한 이름과 같아야 한다.
//      return
//    }
//
//    self.fetchRequest = fetchRequest
    //하지만 모델 편집기에서 fetch request를 정의하여 사용하면, 변경을 할 수 없다.
    //즉, 런타임에서 predicate를 변경할 수 없다. 따라서 delegate 패턴을 사용해 실시간으로 재정렬할 수 없다.
    
    let venueFetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest() //엔티티에서 직접 NSFetchRequest 인스턴스로 가져오면(코드로 생성) predicate를 변경할 수 있다.
    fetchRequest = venueFetchRequest
    //비동기 fetch request가 일반 fetch request를 대체하지 않는다.
    //일반 fetch request를 가져온 후 래퍼해야 한다.
    
    asyncFetchRequest = NSAsynchronousFetchRequest<Venue>(fetchRequest: venueFetchRequest) { [unowned self] (result: NSAsynchronousFetchResult) in
      //NSAsynchronousFetchRequest를 생성한다. 일반 fetch request와 완료 핸들러를 설정해 줘야 한다.
      guard let venues = result.finalResult else {
        //fetch의 결과는 result.finalResult에 있다.
        return
      }
      
      //업데이트
      self.venues = venues
      self.tableView.reloadData()
    }
    
    //일괄 업데이트
    do {
      guard let asyncFetchRequest = asyncFetchRequest else {
        return
      }
      
      try coreDataStack.managedContext.execute(asyncFetchRequest)
      //NSAsynchronousFetchRequest 실행. 일반적인 fetch(_ :)가 아닌 execute(_ :)를 실행해야 한다.
      // Returns immediately, cancel here if you want
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
    
    let batchUpdate = NSBatchUpdateRequest(entityName: "Venue") //엔티티 이름으로 생성
    //NSBatchUpdateRequest : 메모리에 데이터 로드하지 않고, CoreData에서 직접 일괄 업데이트 수행
    batchUpdate.propertiesToUpdate = [#keyPath(Venue.favorite) : true] //일괄 업데이트할 키와 값
    batchUpdate.affectedStores = coreDataStack.managedContext.persistentStoreCoordinator?.persistentStores
    //요청을 처리할 저장소 //NSPersistentStore를 지정해 줘야 한다.
    batchUpdate.resultType = .updatedObjectsCountResultType //업데이트 이후 반환하는 타입
    
    do {
      let batchResult = try coreDataStack.managedContext.execute(batchUpdate) as! NSBatchUpdateResult
      //위에서 반환 받을 타입을 .updatedObjectsCountResultType로 했으므로 업데이트 된 열의 수를 반환한다.
      print("Records updated \(batchResult.result!)")
    } catch let error as NSError {
      print("Could not update \(error), \(error.userInfo)")
    }
    //iOS 8부터 CoreData 객체를 메모리에 가져 오지 않고 일괄적으로 업데이트할 수 있다.
    //이는 NSManagedObjectContext를 사용하지 않고, CoreData로 직접 이동해서 저장하는 것인데,
    //이를 활용하면, 많은 데이터를 업데이트할 때 시간과 메모리를 줄일 수 있다.
    //ex) 메일 앱에서 모두 읽음으로 표시, 일괄 삭제(iOS 9부터는 NSBatchDeleteRequest로 구현)
    //NSBatchDeleteRequest도 NSPersistentStoreRequest의 하위 클래스 이다.
    //사용 전 유효성 검사를 해야 한다.
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == filterViewControllerSegueIdentifier,
      let navController = segue.destination as? UINavigationController, let filterVC = navController.topViewController as? FilterViewController else { //해당 컨트롤러 존재할 때만 진행
        return
      }
    
    filterVC.coreDataStack = coreDataStack //coreDataStack을 D.I 해준다.
    filterVC.delegate = self
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
  }
}

// MARK: - Helper methods
extension ViewController {
  func fetchAndReload() {
    guard let fetchRequest = fetchRequest else {
      return
    }
    
    do {
      venues = try coreDataStack.managedContext.fetch(fetchRequest)
      tableView.reloadData()
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return venues.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
    let venue = venues[indexPath.row] //해당 venue 객체 가져오기
    cell.textLabel?.text = venue.name
    cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
    
    return cell
  }
}

// MARK: - FilterViewControllerDelegate
extension ViewController: FilterViewControllerDelegate {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?) {
    guard let fetchRequest = fetchRequest else {
      return
    }
    
    fetchRequest.predicate = nil //초기화
    fetchRequest.sortDescriptors = nil //초기화
    
    fetchRequest.predicate = predicate
    
    if let sr = sortDescriptor {
      fetchRequest.sortDescriptors = [sr]
    }
    
    fetchAndReload() //해당 조건으로 fetch 후 reload
  }
}

//fetch request를 가져오는 방법에는 5가지가 있다. p.88
// 1 : NSFetchRequest를 제네릭으로 초기화 한 이후, 엔티티를 설정
//let fetchRequest1 = NSFetchRequest<Venue>()
//let entity = NSEntityDescription.entity(forEntityName: "Venue", in: managedContext)! //NSEntityDescription 지정
//fetchRequest1.entity = entity
// 2 : 엔티티 이름을 직접 입력해 초기화 //NSEntityDescription 지정하는 과정을 생략할 수 있다. //1의 간략화
//let fetchRequest2 = NSFetchRequest<Venue>(entityName: "Venue")
// 3 : managed object의 생성시 추가되는 클래스 메서드 활용. //2의 간략화
//let fetchRequest3: NSFetchRequest<Venue> = Venue.fetchRequest()
// 4 : NSManagedObjectModel에서 요청
//let fetchRequest4 = managedObjectModel.fetchRequestTemplate(forName: "venueFR")
// 5 : 4와 비슷하지만 추가 변수 지정
//let fetchRequest5 = managedObjectModel.fetchRequestFromTemplate(withName: "venueFR", substitutionVariables: ["NAME" : "Vivi Bubble Tea"])









