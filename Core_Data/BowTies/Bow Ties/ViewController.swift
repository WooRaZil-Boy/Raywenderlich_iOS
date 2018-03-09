/*
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

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var timesWornLabel: UILabel!
  @IBOutlet weak var lastWornLabel: UILabel!
  @IBOutlet weak var favoriteLabel: UILabel!
  
  // MARK: - Properties
  var managedContext: NSManagedObjectContext! //DI로 가져온다.
  var currentBowtie: Bowtie! //현재 선택한 타이

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    insertSampleData() //샘플 데이터 삽입
    //이미 삽입되어 있으면 guard에 의해 return 된다.
    
    let request: NSFetchRequest<Bowtie> = Bowtie.fetchRequest() //fetch request 생성
    //CoreData 객체를 생성했으면, 엔티티 클래스에서 class function으로 Fetch Request를 가져올 수 있다.
    let firstTitle = segmentedControl.titleForSegment(at: 0)! //첫 번재 segmentControl의 제목
    request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), firstTitle])
    //Fetch에서 검색의 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다.
    //선택된(첫 번째) segmentControl에 해당하는 객체만 가져온다.
    
    do {
      let results = try managedContext.fetch(request) //fetch request를 실행하고 결과값을 받아온다.
      //Bowtie로 fetchRequest를 만들었으므로, 결과값은 Bowtie의 배열이다.
      currentBowtie = results.first //predicate로 검색했으므로 첫 번째 결과만 유효하다.
      populate(bowtie: results.first!)
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }

  // MARK: - IBActions
  @IBAction func segmentedControl(_ sender: Any) {
    guard let control = sender as? UISegmentedControl, let selectedValue = control.titleForSegment(at: control.selectedSegmentIndex) else {
      //선택한 segmentIndex가 유효한 경우에만 실행
      return
    }
    
    let request = NSFetchRequest<Bowtie>(entityName: "Bowtie") //fetch request 생성
    //CoreData 객체를 생성했으면, 엔티티 클래스에서 class function으로 Fetch Request를 가져올 수 있다.
    request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(Bowtie.searchKey), selectedValue])
    //Fetch에서 검색의 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다.
    //선택된(첫 번째) segmentControl에 해당하는 객체만 가져온다.
    
    do {
      let results = try managedContext.fetch(request) //fetch request를 실행하고 결과값을 받아온다.
      //Bowtie로 fetchRequest를 만들었으므로, 결과값은 Bowtie의 배열이다.
      currentBowtie = results.first //predicate로 검색했으므로 첫 번째 결과만 유효하다.
      populate(bowtie: currentBowtie)
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }

  @IBAction func wear(_ sender: Any) {
    let times = currentBowtie.timesWorn
    currentBowtie.timesWorn = times + 1
    currentBowtie.lastWorn = NSDate() //현재 시간
    
    do {
      try managedContext.save() //저장
      populate(bowtie: currentBowtie) //UI 업데이트
    } catch let error as NSError {
      print("Could not fetch \(error), \(error.userInfo)")
    }
  }
  
  @IBAction func rate(_ sender: Any) {
    let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)
    alert.addTextField { textField in
      textField.keyboardType = .decimalPad //키보드 숫자 패드로 변경
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
      guard let textField = alert.textFields?.first else { //guard를 습관화하는 것이 좋다.
        return
      }
      
      self.update(rating: textField.text) //평점 업데이트
    }
    
    alert.addAction(cancelAction)
    alert.addAction(saveAction)
    
    present(alert, animated: true)
  }
}


// MARK: - CoreData
extension ViewController {
  func insertSampleData() {
    let fetch: NSFetchRequest<Bowtie> = Bowtie.fetchRequest() //Fetch Request를 가져온다.
    //CoreData 객체를 생성했으면, 엔티티 클래스에서 class function으로 Fetch Request를 가져올 수 있다.
    fetch.predicate = NSPredicate(format: "searchKey != nil")
    //Fetch에서 검색의 조건을 정의한다. 지정된 조건으로 필터링해서 fetch한다.
    
    let count = try! managedContext.count(for: fetch) //개수를 알아낼 수 있다.
    //fetch해 결과값을 세지 않고도 count로 개수를 쉽게 알아낼 수 있다.
    
    if count > 0 { //결과값이 있다면
      // SampleData.plist data already in Core Data
      return
    }
    
    let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
    //Bundle로 앱 디렉토리의 해당 파일의 경로를 가져올 수 있다.
    let dataArray = NSArray(contentsOfFile: path!)! //지정된 경로 파일로 NSArray를 생성한다.
    
    for dict in dataArray { //배열 loop를 돌면서 각 값에 해당하는 NSManagedObject를 생성한다.
      let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedContext)!
      //NSEntityDescription로 엔티티의 특정 클래스에 접근한다.
      let bowtie = Bowtie(entity: entity, insertInto: managedContext) //NSManagedObject
      let btDict = dict as! [String: Any] //속성 값
      
      bowtie.id = UUID(uuidString: btDict["id"] as! String) //생성된 NSManagedObject에 값을 넣는다.
      //UUID는 고유한 식별 값
      bowtie.name = btDict["name"] as? String
      bowtie.searchKey = btDict["searchKey"] as? String
      bowtie.rating = btDict["rating"] as! Double
      let colorDict = btDict["tintColor"] as! [String: Any] //RGB 딕셔너리
      bowtie.tintColor = UIColor.color(dict: colorDict)
      
      let imageName = btDict["imageName"] as? String
      let image = UIImage(named: imageName!)
      let photoData = UIImagePNGRepresentation(image!)! //저장된 데이터를 png로 반환 //image -> Data
      bowtie.photoData = NSData(data: photoData) //blob
      bowtie.lastWorn = btDict["lastWorn"] as? NSDate
      
      let timesNumber = btDict["timesWorn"] as! NSNumber
      bowtie.timesWorn = timesNumber.int32Value //Int32
      bowtie.isFavorite = btDict["isFavorite"] as! Bool
      bowtie.url = URL(string: btDict["url"] as! String)
    }
    //NSEntityDescription.insertNewObject(forEntityName: into:) 대신 NSEntityDescription.entity(forEntityName: in:)으로 직접 생성
    //NSEntityDescription.insertNewObject(forEntityName: into:)는 대상의 세부사항을 신경쓰지 않고 인스턴스를 쉽게 생성할 수 있다.
    //Appdelegate 주석 코드 참고
    
    try! managedContext.save() //저장
  }
  
  func populate(bowtie: Bowtie) {
    guard let imageData = bowtie.photoData as Data?, let lastWorn = bowtie.lastWorn as Date?, let tintColor = bowtie.tintColor as? UIColor else { //optional 중 nil이 된 것 있는 지 확인
      return
    }
    
    //CoreData에서 fetching 해 온 데이터로 UI 업데이트
    imageView.image = UIImage(data: imageData)
    nameLabel.text = bowtie.name
    ratingLabel.text = "Rating: \(bowtie.rating)/5"
    timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
    
    let dateFormatter = DateFormatter() //Date를 String으로 변환해주는 DateFormatter
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn) //Date 캐스팅
    
    favoriteLabel.isHidden = !bowtie.isFavorite
    view.tintColor = tintColor
  }
  
  func update(rating: String?) {
    guard let ratingString = rating, let rating = Double(ratingString) else {
      //평점을 캐스팅 할 수 없으면 return
      return
    }
    
    do {
      currentBowtie.rating = rating
      
      try managedContext.save() //저장
      populate(bowtie: currentBowtie) //UI 업데이트
    } catch let error as NSError {
      if error.domain == NSCocoaErrorDomain && (error.code == NSValidationNumberTooLargeError || error.code == NSValidationNumberTooSmallError) { //범위 벗어 났을 경우
        //Rating은 0 ~ 5의 값이다. 사용자가 이 범위를 벗어나는 숫자를 입력하면 오류 처리를 해 줘야 한다.
        //이 로직을 입력했을 때 guard로 잡아낼 수도 있으나, CoreData model 자체에서 유효성 검사를 지원한다. p.57
        //이 경우, CoreData에 저장할 때 오류가 나서 catch 블록으로 오게 된다.
        //에러와 에러의 userInfo를 출력해 보면 어떤 부분이 오류가 났는지 알 수 있다.
        rate(currentBowtie) //새로운 평점 입력 알림 창 출력
      } else { //이외의 에러
        print("Could not save \(error), \(error.userInfo)")
      }
    }
  }
}

//NSManagedObject를 상속해 각 엔티티에 대한 고유 클래스를 만든다. (데이터 모델 편집기의 엔티티와 코드의 클래스가 직접 매핑)
//코드에서 CoreData에 신경스지 않고 객체 및 속성을 사용하여 작업할 수 있다.

// MARK: - UIColor Extension
private extension UIColor {
  static func color(dict: [String: Any]) -> UIColor? {
    guard let red = dict["red"] as? NSNumber, let green = dict["green"] as? NSNumber, let blue = dict["blue"] as? NSNumber else { //RGB 모두 가져올 수 없으면 nil
      return nil
    }
    
    return UIColor(red: CGFloat(truncating: red) / 255.0, green: CGFloat(truncating: green) / 255.0, blue: CGFloat(truncating: blue) / 255.0, alpha: 1)
  }
}
