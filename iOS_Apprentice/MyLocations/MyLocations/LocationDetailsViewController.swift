//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 15..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0) //CLLocationCoordinate2D로 CLLocation 객체에서 위도와 경도 정보를 가져온다.
    //CLLocation은 struct로 위도와 경도 외에도 다른 정보들이 있으나, 여기에서는 위도와 경도 정보만 필요하다.
    //이전 뷰에서 위치를 구하지 못하면 이 뷰 컨트롤러로 넘어 올 수 없다. 따라서 옵셔널로 하지 않아도 된다.
    //여기서 latitude와 longitude는 CLLocationDegrees 자료형을 쓰는데 이것은 typealias로 Double이다.
    //typealias를 사용하는 이유는 더 명확하게 하기 위해서이다.
    var placemark: CLPlacemark? //reverse geocoding으로 얻은 주소 정보(도시이름, 거리 이름 등)
    private let dateFormatter: DateFormatter = { //private 이므로 여기에서만 사용할 수 있다.
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter
    }() //클로저로 객체를 생성한다. //Swift에서 전역변수는 항상 lazy로 생성된다.
    //따라서 이 객체가 처음 사용될 때까지 메모리를 점유하지 않는다. //따로 코드를 추가하지 않으면 한 번만 생성이 된다.

    var categoryName = "No Category"
    
    var managedObjectContext: NSManagedObjectContext! //Core Data
//    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//    let context = appDelegate.managedObjectContext
    //이런 식으로 AppDelegate의 managedObjectContext 속성을 불러와 참조를 얻을 수 있다.
    //하지만 이 방법으로는 모든 객체가 AppDelegate에 종속되고, 코드가 꼬이게 된다.
    //디자인 방법에서는 한 클래스가 다른 클래스에 최대한 적게 의존하도록 만드는 것이 좋다.
    //많은 클래스가 AppDelegate에 집접 접근해야 하는 경우 디자인을 다시 생각해 보는 것이 좋다.
    //dependency injection(의존성 주입) :: AppDelegate에서 첫 viewController로 객체를 전달하고, Segue를 통해 다음 viewController로 전달 해 주도록 디자인하는 것이 나은 해결책
    var date = Date() //Location에 날짜 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextView.text = ""
        categoryLabel.text = categoryName
        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude) //8자리까지 표시
        //Format Strings :: 정수 : %d, 부동소수점 : %f, 객체 : %@. Objective-C에서 흔한 표현
        
        if let placemark = placemark { //placemark 있는 경우
            addressLabel.text = string(from: placemark)
        } else { //placemark가 nil인 경우
            addressLabel.text = "No Address Found"
        }
        
        dateLabel.text = format(date: date) //날짜 형태 지정에 DateFormatter 사용
        //하지만 DateFormatter는 메모리를 많이 사용한다. 초기화하는데 시간이 걸림.
        //따라서 한 번 DateFormatter를 만들고 재사용하는 것이 좋다.
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)) //탭 제스처 인식기 //target-action
        //#selector는 Objective-C 문법. #selector로 호출되는 메소드는 Objective-C에서도 액세스 할 수 있어야한다.
        //스토리보드에서도 설정할 수 있다.
        gestureRecognizer.cancelsTouchesInView = false //true(default)로 할 경우, 터치 이벤트는 발생하지만, 셀 클릭이 되지 않는다.
        //제스처가 뷰의 터치 이벤트를 막고 cancel 시키기 때문. 따라서 cancelsTouchesInView를 false로 해 줘야 한다.
        //http://blog.zaemina.com/2014/07/ios-uitableview-touch-event.html
        tableView.addGestureRecognizer(gestureRecognizer) //테이블 뷰에 제스처 인식기 추가
        //스토리보드에서 추가할 때는 @IBAction function을 만들고, cancelsTouchesInView behavior을 설정하고
        //Referencing Outlet Collections의 gestureRecognizers를 tableView로 연결하면 된다.
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) { //테이블 뷰에서 제스처(탭)할 때마다 호출
        let point = gestureRecognizer.location(in: tableView) //tableView 내의 탭 위치
        let indexPath = tableView.indexPathForRow(at: point) //CGPoint로 탭한 위치의 indexPath를 알아낸다.
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0 { //첫 번째 description 입력 란에서는 해제가 되지 않도록
            //indexPath != nil에 의해(short-circuiting), 뒤의 조건들의 indexPath는 nil이 될 수 없다.
            return
        }
        //스토리 보드에서 Dismiss on drag를 선택해 스크롤 시 키보드를 숨길 수 있다(시뮬레이터에선 잘 안 되는 경우 있음).
        
        descriptionTextView.resignFirstResponder() //포커스 해제
        
//        if let indexPath = indexPath, indexPath.section != 0 && indexPath.row != 0 {
//            descriptionTextView.resignFirstResponder()
//        }
        //위의 조건 대신 이런 식으로 쓸 수도 있다.
    }
    
    //MARK: - Prviate Methods
    func string(from placemark: CLPlacemark) -> String { //주소를 반환
        var text = ""
        
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        
        if let s = placemark.locality {
            text += s + ", "
        }
        
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        
        if let s = placemark.postalCode {
            text += s + ", "
        }
        
        if let s = placemark.country {
            text += s
        }
        
        return text
    }
    
    func format(date: Date) -> String { //dateFormatter가 lazy이므로(전역변수)이 메서드가 실행될 때 할당된다.
        return dateFormatter.string(from: date)
    }
}

//Label의 line을 0으로 설정하면, 텍스트에 맞게 크기가 조절된다.

// MARK: - Actions
extension LocationDetailsViewController {
    @IBAction func done() {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        //navigationController가 아닌 self.view로 하면, navigationController가 상위 뷰 이므로, 네비게이션 영역을 다 커버하지 못한다.
        hudView.text = "Tagged"

        let location = Location(context: managedObjectContext) //location 인스턴스 생성
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark
        
        do {
            try managedObjectContext.save() //Core Data에 저장
            afterDelay(0.6) { //hubView를 볼 수 있게 0.6초 딜레이 //trailing closure syntax - 마지막 매개변수가 클로저인 경우
                hudView.hide() //hudView는 done()메서드 범위 내에서 존재하는 로컬 변수 이므로 클로저 내라도 self를 쓰지 않는다.
                self.navigationController?.popViewController(animated: true)
            }
        } catch { //save가 실패할 경우
            fatalCoreDataError(error)
            //NotificationCenter에 알림을 보내고, Appdelegate에서 추가해 두었던 해당 옵저버가 받아 클로저를 실행한다.
//            fatalError("Error: \(error)") //강제 종료 //실제로 릴리즈 할 때는 빼야 한다.
        }
    }
    
    @IBAction func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue) { //@IBAction으로 unwind segue를 처리한다.
        let controller = segue.source as! CategoryPickerViewController //destination이 아닌 source로 segue를 보낸 쪽의 정보를 가져온다.
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    //delegate로도 할 수 있지만, 스토리보드의 unwind를 사용해서 더 간단히 구현할 수 있다.
    //일반적인 segue가 화면을 여는 데 사용된다면, unwind segue는 화면을 닫는 데에 사용된다
}

//MARK: - Navigations
extension LocationDetailsViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let controller = segue.destination as! CategoryPickerViewController
            controller.selectedCategoryName = categoryName
        }
    }
}

//MARK: - UITableViewDataSource
extension LocationDetailsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { //주소 길이에 따라 셀의 높이를 변경해 줘야 한다. //일반적으로 각 셀의 높이가 같을 경우에는 스토리보드에서 간단히 설정해 줄 수 있다.
        if indexPath.section == 0 && indexPath.row == 0 { //Description cell
            return 88
        } else if indexPath.section == 2 && indexPath.row == 2 { //address cell
            addressLabel.frame.size = CGSize(width: view.bounds.size.width - 120, height: 10000)
            //레이블의 너비를 화면 너비보다 120 작게, 높이를 충분히 크게
            addressLabel.sizeToFit() //레이블의 크기를 적절하게 다시 조정. 이미 viewDidLoad에서 addressLabel에 text를 입력해 뒀다.
            addressLabel.frame.origin.x = view.bounds.size.width - addressLabel.frame.size.width - 16
            //sizeToFit()으로 레이블의 오른쪽과 아래쪽의 여유공간이 제거된다. x위치가 16pt 여백을 두도록 배치
            
            return addressLabel.frame.size.height + 20 //적절한 여분을 추가하고(상하, 10px) 반환
        } else { //이외의 셀
            return 44
        }
    }
    //frame과 bounds는 보통 width, height는 동일하나, x, y가 다르다.
    //frame은 부모 요소를 기준으로 한다. UIView의 위치가 크기를 설정하는 경우 등에 사용한다.
    //bounds는 자신을 기준으로 한다. 자신의 내부에 뭔가를 그릴 때나 터치 영역 판정 등에 사용한다.
}

//MARK: - UITableViewDelegate
extension LocationDetailsViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath //첫 섹션과 두 번재 섹션은 선택하거나 탭을 해 메시지를 적는 TextView가 있는데, 기본값인 retun nil 로 하면, 여백이 있는 가장가리를 부분을 탭하면 선택되지가 않아 버그처럼 느껴질 수 있다.
            //이런 경우 선택된 indexPath를 return 하면 여백이 있는 가장자리를 탭해도 선택이 된다.
        } else { //세 번째 세션은 읽기 전용 셀들만 있으므로 선택할 필요가 없다.
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 { //위의 tableView (_ : willSelectRowAt :)에서 return indexPath를 했기 때문에 여백이 있는 가장자리를 탭해도 선택이 된다.
            descriptionTextView.becomeFirstResponder() //텍스트 뷰 포커스
        }
    }
}

//키보드가 활성화되면 제거할 마땅한 방법이 없다. 그리고 키보드의 크기가 크다.

//데이터 모델을 변경하면 데이터 베이스 파일도 새로 적용해 줘야 한다.
