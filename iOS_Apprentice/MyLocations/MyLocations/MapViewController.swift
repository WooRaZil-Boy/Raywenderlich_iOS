//
//  MapViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 23..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import MapKit
import CoreData

//Map 축소/확대는 시뮬레이터에서 Alt(Option)키 누른 상태에서 마우스 드래그
//Xcode 버전에 따라 Project Settings - Capabilities에서 설정해야 할 수도 있다.

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet { //annotation을 눌러 수정한 경우나, 새로운 위치를 저장했을 때 맵에 업데이트를 반영하기 위해
            //didSet은 처음 값이 초기화되면서 할당 될 때에는 호출되지 않고, 초기화 이후 값이 변할 때마다 호출된다.
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { _ in //와일드 카드
                //CoreData는 저장소가 변경될 때 마다 여러가지 알림을 발송하는 데 이런 알림들을 추가해 구독하면 업데이트를 쉽게 구현할 수 있다.
                //Notification.Name.NSManagedObjectContextObjectsDidChanged은 데이터가 변경될 때마다 호출된다.
                //옵저버를 추가해 이벤트가 발생할 때마다 클로저를 실행한다.
                if self.isViewLoaded { //뷰가 현재 메모리에 로드 되었다면
                    //이 뷰 컨트롤러는 Tabbar에 속하므로, 화면이 전환되어 나타나기 전에는 실제로 스토리보드에서 로드되지 않는다.
                    //managedObjectContext는 AppDelegate에서 앱 실행 직후, D.I 되었기 때문에 MapViewController보다 먼저 메모리가 할당된다.
                    //Tag탭에서 새로운 위치를 CoreData에 저장하는 경우, managedObjectContext 값이 변하게 된다.
                    //즉, didSet이 이 뷰 컨트롤러의 viewDidLoad보다 먼저 실행되는 경우도 있다.
                    //따라서 새 위치를 annotation할 때 아직 뷰가 로드되지 않았을 수도 있으므로 뷰가 로드되었는지 확인하는 것이 필요하다.
                    self.updateLocations() //업데이트 //수 백개의 annotation이 있는 경우 효율적인 업데이트 방법은 아니다.
                    
                    //더 효율적으로 업데이트 할 경우, 클로저에서 반환하는 notification(위에서는 쓰지 않으므로 와일드 카드로 표현)를 받아 해당 항목만 찾아내야 한다.
//                    if let dictionary = notification.userInfo {
//                        print(dictionary["inserted"])
//                        print(dictionary["deleted"])
//                        print(dictionary["updated"])
//                    }
                }
            }
        } //didSet로 추가했기에 managedObjectContext의 값이 바뀔 때마다 옵저버 중복 추가하는 거 아닌가??
    }
    var locations = [Location]()
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLocations() //현재 위치 표시
        
        if !locations.isEmpty { //지도 이동
            showLocations()
        }
    }
    
    // MARK:- Private methods
    func updateLocations() {
        mapView.removeAnnotations(locations) //모든 핀 제거
        
        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>() //NSFetchRequest는 데이터 저장소에서 가져올 객체를 설명 //제네릭
        fetchRequest.entity = entity //엔티티 추가
        
        locations = try! managedObjectContext.fetch(fetchRequest) //데이터 불러와 저장
        //do - try - catch로 가져와야 되지만 실패하지 않을 것이라는 확신 있다면 try!로 대체할 수 있다.
        mapView.addAnnotations(locations) //각 위도에 핀 추가
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0: //annotation이 없는 경우, 현재 사용자 위치를 지도 중앙으로
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1: //annotation이 하나 있는 경우, 그 위치를 지도 중앙으로
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default: //annotation이 2개 이상 있는 경우 //좌표들 중 topLeft와 bottomRight의 중앙으로 이동
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            //-90 : 최남단, 180 : 최동단, 평면 지도에서 오른쪽 아래 끝
            //topLeft는 annotation 좌표들 중 가장 왼쪽 위에 위치하는 좌표를 찾아야 하기 때문에, 대척점이 되는 좌표를 기본값으로 한다.
            //좌표의 값이 topLeft 기본값(-90, 180)보단 왼쪽 위에 위치하는 것이 거의 확실하기 때문
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            //90 : 최북단, -180 : 최서단, 평면 지도에서 왼쪽 위쪽 끝
            //bottomRight는 annotation 좌표들 중 가장 오른쪽 밑에 위치하는 좌표를 찾아야 하기 때문에, 대척점이 되는 좌표를 기본값으로 한다.
            //좌표의 값이 bottomRight 기본값(90, -180)보단 오른쪽 밑에 위치하는 것이 거의 확실하기 때문
            
            //위도(latitude)는 북위 90°(90) ~ 남위 90°(-90) 까지
            //경도(longitude)는 동경 180°(180) ~ 서경 180°(-180) 까지
            //0, 0이 적도와 그리니치 천문대 교차점
            
            for annotation in annotations { //반복문을 통해 topLeft, bottomRight값을 업데이트
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude) //큰 값 반환
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude) //작은 값 반환
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2, longitude: topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2) //중심
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) * extraSpace, longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace) //MKCoordinateSpan 지도의 너비와 높이
            //abs는 절대값으로 항상 양수로 만든다.
            //span이 커질 수록 지도가 더 넓은 영역을 보여준다 (줌이 작아진다)
            
            region = MKCoordinateRegion(center: center, span: span) //해당 좌표를 span영역 만큼 표시
        }
        
        return mapView.regionThatFits(region)
    }
}

//MARK: - Actions
extension MapViewController {
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000) //사용자 위치 중심으로 양방향 1000m 영역으로 확대
        mapView.setRegion(mapView.regionThatFits(region), animated: true) //영역 이동
    }
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true) //영역 이동
    }
    
    @objc func showLocationDetails(_ sender: UIButton) { //#selector로 호출되기 때문에 @objc 키워드가 필요하다.
        performSegue(withIdentifier: "EditLocation", sender: sender)
        //segue가 뷰 컨트롤러의 특정 컨트롤에 연결되어 있지 않다면, 코드로 수행해 줘야 한다.
        //sender로 button을 전달하므로 tag를 통해 Location을 가져올 수 있다. 
    }
}

//MARK: - Navigations
extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag] //tag를 통해 Location을 가져온다.
            controller.locationToEdit = location
        }
    }
}

//MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? { //cellForRowAt와 비슷
        guard annotation is Location else { //annotation이 Location 객체인 경우에만 실행. 아닌 경우는 nil반환
            //is로 특정 타입의 서브클래스 인지를 체크한다. //as는 특정 타입의 서브 클래스로 캐스팅한다.
            return nil //else에 해당될 때 실행 //정상적 작동하면 else 블록 건너 뛴다. //if로 쓸 수도 있다.
            //예외 처리 시 더 깔끔하게 정리할 수 있다.
        }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) //재사용 annotationView 생성
        
        if annotationView == nil { //재사용할 annotationView를 찾지 못하면 생성
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier) //MKPinAnnotationView 생성
            pinView.isEnabled = true //활성화 여부. default는 ture. false이면 annotation이 선택되지 않는다.
            pinView.canShowCallout = true //추가 정보 풍선창 표시 여부. true이면 annotation 선택 시 설명 풍선 창이 추가 된다.
            pinView.animatesDrop = false //annotation이 추가될 때 애니메이션 여부
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1) //녹색
            
            let rightButton = UIButton(type: .detailDisclosure) //상세보기 있는 버튼 생성
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside) //버튼 이벤트 연결
            pinView.rightCalloutAccessoryView = rightButton //추가 정보 풍선창에 버튼 연결
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation //annotation 연결
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton //추가 정보 풍선창에 버튼
            if let index = locations.index(of: annotation as! Location) { //나중에 Location 객체 찾기 위한 태그 설정
                button.tag = index
            }
        }
        
        return annotationView
    }
}
