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
  lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
  }()

  var managedContext: NSManagedObjectContext!
  var currentDog: Dog?

  // MARK: - IBOutlets
  @IBOutlet var tableView: UITableView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") //셀 등록
    
    let dogName = "Fido"
    let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest() //Dog와 연결되 fetch request를 가져온다.
    dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName) //필터링
    //Fetch에서 검색의 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다. //Fido라는 이름의 Dog 검색
    
    do { //Find or Create Pattern
      let results = try managedContext.fetch(dogFetch)
      
      if results.count > 0 {
        //Fido found, use Fido
        currentDog = results.first
      } else {
        //Fido not found, create Fido //앱 처음 실행 시
        currentDog = Dog(context: managedContext) //managedContext로 Dog 객체 생성
        currentDog?.name = dogName //이름 지정
        
        try managedContext.save() //저장
      }
    } catch let error as NSError {
      print("Fetch error: \(error) description: \(error.userInfo)")
    }
  }
}

// MARK: - IBActions
extension ViewController {
  @IBAction func add(_ sender: UIBarButtonItem) {
    // Insert a new Walk entity into Core Data
    let walk = Walk(context: managedContext) //managedContext로 Walk 객체 생성
    walk.date = NSDate() //현재 시간
    
    // Insert the new Walk into the Dog's walks set
    if let dog = currentDog, let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
      //mutableCopy로 객체를 복사한다.
      //실제 walks의 유형인 NSOrderedSet은 변경할 수 없다. 따라서 변경 가능한 복사본을 만들어 작업 후 교체한다.
      walks.add(walk) //walks 배열에 추가(실제로는 OrderedSet)
      dog.walks = walks //walks 배열 업데이트 //교체
    }
    //CoreData managedObject 생성시 추가된 addToWalks(_ :)로 쉽게 처리할 수도 있다.
    //currentDog?.addToWalks(walk)
    
    // Save the managed object context
    do {
      try managedContext.save() //저장
    } catch let error as NSError {
      print("Save error: \(error), description: \(error.userInfo)")
    }
    
    // Reload table view
    tableView.reloadData()
  }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let walks = currentDog?.walks else { //없으면 1
      return 1
    }
    
    return walks.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    guard let walk = currentDog?.walks?[indexPath.row] as? Walk, let walkDate = walk.date as Date? else {
      //guard를 중간에 써줄 수도 있다.
      return cell
    }
    
    cell.textLabel?.text = dateFormatter.string(from: walkDate)
    
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "List of Walks"
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //항목을 에디트(삭제)할 때, 특정 셀을 편집할 수 있는 지 여부
    return true
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //지정된 행의 삽입 또는 삭제를 요청 //테이블 뷰 에디트 시 (삽입, 삭제) 시 해당 변경을 커밋하도록 요청
    //삽입 insertRows(at: with:) //삭제 deleteRows(at)
    guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk, editingStyle == .delete else {
      //해당 객체를 가져올 수 있고, 에디팅 타입이 삭제일 때만 진행
      return
    }
    
    managedContext.delete(walkToRemove) //삭제
    
    do {
      try managedContext.save() //저장 //저장하기 전에는 최종 변경이 영향을 주징 ㅏㄴㅎ는다.
      
      tableView.deleteRows(at: [indexPath], with: .automatic) //테이블 뷰에서 삭제 //UI 업데이트
    } catch let error as NSError {
      print("Saving error: \(error), description: \(error.userInfo)")
    }
  }
}

//데이터 모델에서 Array 속성을 추가할 수는 없다. 대신 relation을 만들어서 구현할 수 있다.
//속성은 기본적으로 1 대 1 관계이다. 이를 Many로 바꿔 줄 수 있다. p.75

//Inverse 속성은 두 개의 속성이 관계되어 있을 때, 한 쪽의 속성이 바뀔 때 다른 한 쪽도 유기적으로 바뀌는 지에 대한 설정.


