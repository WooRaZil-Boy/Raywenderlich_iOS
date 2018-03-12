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

protocol FilterViewControllerDelegate: class {
  func filterViewController(filter: FilterViewController, didSelectPredicate predicate: NSPredicate?, sortDescriptor: NSSortDescriptor?)
  //사용자가 정렬 / 필터 조합을 할 때마다 알려준다.
  //fetch request의 경우, 최적화를 위해 꼭 필요한 데이터만을 가져오도록 해야 한다.
}

class FilterViewController: UITableViewController {

  @IBOutlet weak var firstPriceCategoryLabel: UILabel!
  @IBOutlet weak var secondPriceCategoryLabel: UILabel!
  @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
  @IBOutlet weak var numDealsLabel: UILabel!
  
  // MARK: - Properties
  var coreDataStack: CoreDataStack!
  
  //가격 필터링
  lazy var cheapVenuePredicate: NSPredicate = { //필터링
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$")
    //Fetch에서 검색할 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다.
    //가격 범주가 "$"인 것만 검색
  }()
  lazy var moderateVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$")
    //Fetch에서 검색할 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다.
    //가격 범주가 "$$"인 것만 검색
  }()
  lazy var expensiveVenuePredicate: NSPredicate = {
    return NSPredicate(format: "%K == %@", #keyPath(Venue.priceInfo.priceCategory), "$$$")
    //Fetch에서 검색할 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다.
    //가격 범주가 "$$$"인 것만 검색
  }()
  
  //거래 필터링
  lazy var offeringDealPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0", #keyPath(Venue.specialCount))
  }()
  
  //거리 필터링
  lazy var walkingDistancePredicate: NSPredicate = {
    return NSPredicate(format: "%K < 500", #keyPath(Venue.location.distance))
  }()
  
  //팁 필터링
  lazy var hasUserTipsPredicate: NSPredicate = {
    return NSPredicate(format: "%K > 0", #keyPath(Venue.stats.tipCount))
  }()
  
  //각각 필터링을 AND, OR, NOT을 활용할 수도 있다.
  
  //정렬 //NSSortDescriptor로 정렬하면, SQLite에서 정렬하므로 빠르고 효율적이다.
  lazy var nameSortDescriptor: NSSortDescriptor = {
    let compareSelector = #selector(NSString.localizedStandardCompare(_:)) //비교 작업위한 selector
    //로컬 언어규칙에 따라 정렬
    return NSSortDescriptor(key: #keyPath(Venue.name), ascending: true, selector: compareSelector)
  }()
  lazy var distanceSortDescriptor: NSSortDescriptor = {
    return NSSortDescriptor(key: #keyPath(Venue.location.distance), ascending: true)
  }()
  lazy var priceSortDescriptor: NSSortDescriptor = {
    return NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory), ascending: true)
  }()
  
  weak var delegate: FilterViewControllerDelegate?
  var selectedPredicate: NSPredicate? //현재 선택된 NSPredicate
  var selectedSortDescriptor: NSSortDescriptor? //현재 선택된 NSSortDescriptor

  // MARK: - Price section
  @IBOutlet weak var cheapVenueCell: UITableViewCell!
  @IBOutlet weak var moderateVenueCell: UITableViewCell!
  @IBOutlet weak var expensiveVenueCell: UITableViewCell!

  // MARK: - Most popular section
  @IBOutlet weak var offeringDealCell: UITableViewCell!
  @IBOutlet weak var walkingDistanceCell: UITableViewCell!
  @IBOutlet weak var userTipsCell: UITableViewCell!
  
  // MARK: - Sort section
  @IBOutlet weak var nameAZSortCell: UITableViewCell!
  @IBOutlet weak var nameZASortCell: UITableViewCell!
  @IBOutlet weak var distanceSortCell: UITableViewCell!
  @IBOutlet weak var priceSortCell: UITableViewCell!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateCheapVenueCountLabel()
    populateModerateVenueCountLabel()
    populateExpensiveVenueCountLabel()
    populateDealsCountLabel()
  }
}

// MARK: - IBActions
extension FilterViewController {

  @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
    delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
    //필터 뷰 컨트롤러에서 Search를 누를 때마다 delegate에 알려준다.
    //delegate는 선택된 필터와 정렬을 받아 fetch한다.
    dismiss(animated: true)
  }
}

// MARK - UITableViewDelegate
extension FilterViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else {
      return
    }
    
    // Price selction
    switch cell {
    case cheapVenueCell:
      selectedPredicate = cheapVenuePredicate
    case moderateVenueCell:
      selectedPredicate = moderateVenuePredicate
    case expensiveVenueCell:
      selectedPredicate = expensiveVenuePredicate
      
    // Most Popular section
    case offeringDealCell:
      selectedPredicate = offeringDealPredicate
    case walkingDistanceCell:
      selectedPredicate = walkingDistancePredicate
    case userTipsCell:
      selectedPredicate = hasUserTipsPredicate
      
    // Sort By section
    case nameAZSortCell:
      selectedSortDescriptor = nameSortDescriptor
    case nameZASortCell:
      selectedSortDescriptor = nameSortDescriptor.reversedSortDescriptor as? NSSortDescriptor
      //별도의 NSSortDescriptor를 작성할 필요없이 nameSortDescriptor를 반대로 하면 된다.
    case distanceSortCell:
      selectedSortDescriptor = distanceSortDescriptor
    case priceSortCell:
      selectedSortDescriptor = priceSortDescriptor
      
    default:
      break
    }
    
    //선택한 셀에 맞춰 Predicate를 설정해 준다.
    
    cell.accessoryType = .checkmark
  }
}

// MARK: - Helper methods
extension FilterViewController {
  func populateCheapVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue") //카운트만 가져올 것이므로 NSNumber
    fetchRequest.resultType = .countResultType
    //• .managedObjectResultType : managed objects를 반환(기본값)
    //• .countResultType : fetch request에 일치하는 managed objects의 수 반환
    //• .dictionaryResultType : 다른 계산을 위한 타입 반환
    //• .managedObjectIDResultType : managed objects의 식별자 반환. iOS 5 이전에 주로 사용. 현재는 거의 쓰지 않는다.
    fetchRequest.predicate = cheapVenuePredicate //필터링
    
    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first!.intValue
      firstPriceCategoryLabel.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
    //managedObjectResultType(default)를 가져와 배열의 수를 세도 되지만, 단순 카운트만 필요할 때는 이 방법이 성능 최적화된다.
  }
  
  func populateModerateVenueCountLabel() {
    let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue") //카운트만 가져올 것이므로 NSNumber
    fetchRequest.resultType = .countResultType
    //• .managedObjectResultType : managed objects를 반환(기본값)
    //• .countResultType : fetch request에 일치하는 managed objects의 수 반환
    //• .dictionaryResultType : 다른 계산을 위한 타입 반환
    //• .managedObjectIDResultType : managed objects의 식별자 반환. iOS 5 이전에 주로 사용. 현재는 거의 쓰지 않는다.
    fetchRequest.predicate = moderateVenuePredicate //필터링
    
    do {
      let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
      let count = countResult.first!.intValue
      secondPriceCategoryLabel.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
    //managedObjectResultType(default)를 가져와 배열의 수를 세도 되지만, 단순 카운트만 필요할 때는 이 방법이 성능 최적화된다.
  }
  
  func populateExpensiveVenueCountLabel() {
    let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest() //Venue형을 가져온다.
    fetchRequest.predicate = expensiveVenuePredicate
    
    do {
      let count = try coreDataStack.managedContext.count(for: fetchRequest)
      //fetchRequest.resultType = .countResultType를 사용하지 않고 일반적인 managedObjectResultType를
      //쓰면서 count를 가져올 수도 있다. count(for: )로 fetching하면 된다.
      thirdPriceCategoryLabel.text = "\(count) bubble tea places"
    } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
  }
  
  func populateDealsCountLabel() { //이런 식의 계산된 값을 가져오는 경우에는 기술적으로 꼭 사용해야 하는지 먼저 생각.
    let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue") //결과가 NSDictionary
    fetchRequest.resultType = .dictionaryResultType //평균, 최대, 최소, 합계 등을 구할 수 있다.
    //• .managedObjectResultType : managed objects를 반환(기본값)
    //• .countResultType : fetch request에 일치하는 managed objects의 수 반환
    //• .dictionaryResultType : 다른 계산을 위한 타입 반환
    //• .managedObjectIDResultType : managed objects의 식별자 반환. iOS 5 이전에 주로 사용. 현재는 거의 쓰지 않는다.
    
    let sumExpressionDesc = NSExpressionDescription() //fetch request와 함께 사용하는 특수 속성 Description
    sumExpressionDesc.name = "sumDeals" //Dictionary에서 가져올 키 값을 지정해 준다.
    
    let specialCountExp = NSExpression(forKeyPath: #keyPath(Venue.specialCount)) //표현식 지정
    //NSPredicate에 쓰일 표현식 인자 생성
    //NSPredicate은 NSExpression로 표현되는 두 개의 식으로 기반한다.
    //NSExpression으로 최소, 최대, 평균, 중앙갑, 절대갑 등을 가져올 수 있다.
    sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [specialCountExp]) //합산
    sumExpressionDesc.expressionResultType = .integer32AttributeType //specialCount가 int32
    //표현식의 반환형
    
    fetchRequest.propertiesToFetch = [sumExpressionDesc] //fetch에서 반환해야하는 속성 지정
    
    do {
      let results = try coreDataStack.managedContext.fetch(fetchRequest) //fetch 후
      let resultDict = results.first!
      let numDeals = resultDict["sumDeals"]! //위에서 설정해둔 키 값으로 가져온다.
      numDealsLabel.text = "\(numDeals) total deals"
    } catch let error as NSError {
      print("Count not fetch \(error), \(error.userInfo)")
    }
  }
}

//필터는 가격, 인기, 정렬 방법으로 구성

