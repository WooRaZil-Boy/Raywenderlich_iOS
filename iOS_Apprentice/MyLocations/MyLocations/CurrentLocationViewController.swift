//
//  CurrentLocationViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 10..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import CoreLocation //로케이션 프레임워크

class CurrentLocationViewController: UIViewController {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    let locationManager = CLLocationManager() //CLLocationManager : GPS 좌표를 알려주는 객체
    //그렇다고 바로 GPS좌표를 사용할 수 있는 것은 아니다. startUpdatingLocation()으로 좌표를 받아와야 한다.
    //바로 GPS좌표를 받아온다면, 배터리와 메모리가 낭비되므로 필요한 경우에만 받아오고, 불필요한 경우 중지시키면 된다.
    var location: CLLocation? //위치 정보를 못 가져오거나, 가져오는 중일 경우 nil이 될 수 있으므로 옵셔널
    var updatingLocation = false //flag
    var lastLocationError: Error? //오류가 없으면 nil이 되므로 옵셔널
    
    let geocoder = CLGeocoder() //지오코딩 수행
    var placemark: CLPlacemark? //주소결과 //아직 위치가 없거나 주소를 받아오지 못할 수 있으므로 옵셔널
    var performingReverseGeocoding = false //flag
    var lastGeocodingError: Error? //오류가 없으면 nil이 되므로 옵셔널
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true //네비게이션 바 숨기기(스토리 보드에서 할 수도 있음 : 전체를 숨김)
        //이 설정은 해당 네비게이션 바가 포함된 모든 뷰의 네비게이션 바에 영향을 준다.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false //다음 뷰에서는 네비게이션 바가 필요하므로 다시 보이게 해 준다.
        //이 설정은 해당 네비게이션 바가 포함된 모든 뷰의 네비게이션에 영향을 준다.
        
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func updateLabels() { //이 하나의 메서드의 모든 논리를 구현하면, 뒤에 위치를 찾았든, 오류가 났든, updateLabels()만 호출해 주면 된다.
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude) //8자리까지 표시
            //Format Strings :: 정수 : %d, 부동소수점 : %f, 객체 : %@. Objective-C에서 흔한 표현
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude) //8자리까지 표시
            tagButton.isHidden = false
            messageLabel.text = ""
            
            if let placemark = placemark { //ReverseGeocoding 결과 주소가 있으면
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding { //ReverseGeocoding 중 (클로저에서 값을 정상적으로 가져오거나 오류 발생 후 performingReverseGeocoding이 false가 된다.)
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil { //ReverseGeocoding 결과 오류 있는 경우
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
        } else { //location 가져 오지 못한 경우
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            
            let statusMessage: String
            if let error = lastLocationError as NSError? { //에러난 경우
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue { //권한 없는 경우
                    //이전에 이미 확인했지만, 그래도 다시 한 번 확인
                    statusMessage = "Location Services Disabled"
                } else { //타이머 60초 경과 되서 에러가 되면 여기로
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() { //위치찾기를 중지한 경우
                statusMessage = "Location Services Disabled"
            } else if updatingLocation { //오류 없고 정상적. 첫 번째 위치가 수신 대기 전의 상태
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        
        configureGetButton()
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() { //위치찾기 서비스가 중지되지 않은 경우
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //정확도 최대 10미터
            locationManager.startUpdatingLocation() //startUpdatingLocation()으로 좌표를 받아와야 사용 가능하다.
            //startUpdatingLocation()을 시작하면 멈춤 지시가 따로 있을 때까지 계속해서 GPS 정보를 업데이트 하며, 정확도가 향상된다.
            updatingLocation = true
            
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false) //60 초 후에 didTimeOut를 self에서 실행하는 타이머 객체
            //selector는 Objective-C에서 메서드 이름 설명에 사용한다. 스위프트에서는 #selector()로 생성
        }
    }
    
    func stopLocationManager() {
        if updatingLocation { //업데이트 중일 때에만 작동
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            
            if let timer = timer { //타이머가 있다면
                timer.invalidate() //타이머 해제 //60초가 경과했거나, 사용자가 중지 버튼을 눈러 종료했을 경우.
            }
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    func string(from placemark: CLPlacemark) -> String { //불완전하거나 누락된 주소 요소가 있을 수 있다.
        var line1 = ""

        if let s = placemark.subThoroughfare { //house number
            line1 += s + " "
        }
        
        if let s = placemark.thoroughfare { //street name
            line1 += s
        }
        
        var line2 = ""
        
        if let s = placemark.locality { //the city
            line2 += s + " "
        }
        
        if let s = placemark.administrativeArea { //the state or province
            line2 += s + " "
        }
        
        if let s = placemark.postalCode { //zip code
            line2 += s
        }
        
        return line1 + "\n" + line2 //"\n" 줄바꿈
    }
    
    @objc func didTimeOut() { //1분 후에도 유요한 위치를 찾지 못한 경우 강제로 종료
        //#selector는 Objective-C의 개념
        //#selector로 메서드를 호출하려면, Swift에서 뿐만 아니라 Objective-C에서도 해당 메서드에 액세스 할 수 있어야 한다.
        //@objc 키워드를 사용해서 Objective-C에서 액세스 할 수 있는 메서드(클래스, 속성, 열거형 ...)를 식별 할 수 있다.
        print("*** Time out")
        
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(domain: "MyLocationsErrorDomain", code: 1, userInfo: nil)
            //NSError 객체를 만들어 lastLocationError 인스턴스 변수에 저장 후 updateLabels()를 실행하면 따로 로직을 바꿀 필요가 없다.
            updateLabels()
        }
    }
}

//iPhone은 위치를 가져오는 데 3가지 방법을 사용한다.
// 1. Cell tower 삼각측량 : 신호가 있는 경우. 정확하지는 않다.
// 2. Wi-Fi : 삼각측량보다 잘 작동하지만, Wi-Fi 라우터가 있어야 한다.
// 3. GPS : 가장 정확하지만 느리고, 실내에서 잘 작동하지 않는다.
//Core Location은 GPS를 수신하는 동안, Cell tower와 Wi-Fi로 위치를 파악하고, 정확한 GPS가 수신되면 업데이트한다.

//MARK: - Actions
extension CurrentLocationViewController {
    @IBAction func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus() //GPS 권한 얻어오기
        
        if authStatus == .notDetermined { //아직 권한을 얻지 못한 경우
            locationManager.requestWhenInUseAuthorization() //권한 설정
            
            return
        }
        
        if authStatus == .denied || authStatus == .restricted { //거부 됐거나 제한 됐을 경우
            showLocationServicesDeniedAlert()
            
            return
        }
        
        if updatingLocation { //위치 정보 업데이트 중에 버튼 눌렀다면 취소 //앱이 어떤 상태에 있는지를 결정하기 위해 updatingLocation 플래그를 사용
            stopLocationManager()
        } else { //위치 정보 업데이트 중이 아니었다면 새로운 위치 정보 업데이트
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        
        updateLabels()
    }
}

//MARK: - Navigations
extension CurrentLocationViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
        }
    }
}

//MARK: - CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Error 객체에는 도메인, 코드가 있다. //여기서 도메인은 kCLErrorDomain, 코드는 CLError.denied로 식별
        //k 접두사는 상수를 나타낼 때 흔히 썼었다.
        print("didFailWithError \(error)")
        
        if (error as NSError).code == CLError.locationUnknown.rawValue { //error의 코드로 에러 종류를 알아낼 수 있다. //rawValue를 가지고 있는 NSError로 캐스팅
            return
        }
        
        //CLError.locationUnknown - 위치는 현재 알 수 없지만 Core Location은 계속 시도
        //CLError.denied - 사용자가 위치 서비스를 사용하기위한 앱 권한을 거부
        //CLError.network - 네트워크 관련 오류
        
        lastLocationError = error //에러 알림을 위한 저장
        
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //위도와 경도 좌표를 포함하는 CLLocation 객체의 배열을 제공. //고도, 속도 등 다른 정보도 제공
        let newLocation = locations.last! //startUpdatingLocation()로 정보를 받아오면 계속해서 정보가 업데이트 되면서 배열에 추가 되기 때문에, 최근 정보(배열의 마지막 객체)를 가져와야 한다.
        //이동 중에 사용하는 경우도 있으므로, 따로 stopUpdatingLocation()을 하지 않는 이상 계속해서 위치 정보를 업데이트한다.
        print("didUpdateLocations \(newLocation)")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 { //새로 받은 위치 정보가 5초 이상 경과된 정보라면
            return //업데이트 하지 않는다.
        }
        
        if newLocation.horizontalAccuracy < 0 { //새 위치정보가 이전 위치정보보다 더 정확한지 판별. horizontalAccuracy으로 판별할 수 있다.
            return //horizontalAccuracy가 0보다 작으면 유효하지 않은 값이다. //horizontalAccuracy 값이 클수록 오차범위가 크다.
        }
        
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude) //Double 값이 가질 수 있는 최대 값
        if let location = location {
            distance = newLocation.distance(from: location) //이전 위치 정보가 있는 경우에는 새 위치와 이전 위치 사이의 거리를 구한다.
        } //GPS로 위치를 찾지 않는 경우(iPod touch 혹은, 통신 상태가 좋지 않을 때), Wi-Fi로 위치를 찾게 되는데, 오차가 커진다.
        //이 경우 desiredAccuracy로만 정확도를 판단하기 쉽지 않기 때문에, distance로 정확도 계산하는 코드를 추가해 준다.
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy { //처음 업데이트 됐거나, 업데이트 해도 될 만큼 정확도가 높은 경우(newLocation의 horizontalAccuracy가 이전 저장된 위치의 horizontalAccuracy보다 낮을 경우)
            //horizontalAccuracy는 오차범위. horizontalAccuracy가 적을 수록 정확도가 높다. (ex) horizontalAccuracy 100은 100미터 정확도, 10은 10미터 정확도)
            //여기서 location!을 썼는데, Short circuiting에 의해 location이 nil이 아닌 것이 보장되기 때문이다.
            lastLocationError = nil //위치 찾기에 성공했으므로 이전의 오류가 있었다면 지워준다.
            location = newLocation //위치 정보 업데이트
            
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy { //새로운 위치정보의 정확도가 목표치에 다다르면 (kCLLocationAccuracyNearestTenMeters == 10m)
                print("*** We're done!")
                stopLocationManager() //종료
                //이 앱은 네비게이션 수준의 정확도를 얻고자 하는 것이 아니기 때문에, 일정한 정확도가 보장되면 위치찾기를 종료해 배터리 소모와 메머리 점유를 줄인다.
                //City Bicycle Ride, City Run 등의 옵션으로 설정하면 정확도는 향상되지만 이전과 크게 다른 좌표가 나오면 업데이트 되지 않는다.
                //앱의 목적과 상황에 맞는 설정이 필요.
                
                if distance > 0 { //reverse geocoding 중이라도 최근 위치에 대한 reverse geocoding이 필요하다.
                    performingReverseGeocoding = false //false로 설정해 최근 위치에 대해 항상 지오 코딩이 수행되도록한다.
                    //거리가 0이면이 위치는 이전 위치와 동일한 위치이므로 지오코딩을 할 필요가 없다.
                }
            }
            updateLabels()
            
            if !performingReverseGeocoding { //위치를 찾았고, 아직 리버스 지오코딩 하지 않은 상태에서만 실행
                print("*** Going to geocode")
                
                performingReverseGeocoding = true //flag
                geocoder.reverseGeocodeLocation(newLocation) { placemarks, error in //CLGeocoder는 delegate 대신 클로저로 결과 반환
                    //위치를 찾았거나 오류가 난 경우 실행된다.
                    //delegate 패턴에서는 오류가 난 경우, 제대로 위치를 찾은 경우 등 여러가지로 코드가 나뉘어지나, 클로저에서는 실행 코드에 이어서 결과를 처리할 수 있다.
                    //delegate와 closure는 비슷한 패턴
                    
                    //Reverse geocoding으로 GPS 좌표를 사람이 읽을 수 있는 주소로 바꿔준다. //반대로도 가능하다.
                    //reverseGeocodeLocation로 지오코딩 서버에 변환된 주소를 요청한다. 단기간에 많은 요청을 하면 실패할 수 있다. - 필요한 경우에만 제한적으로 실행.
                    //중국에서 중국 이외의 주소를 reverseGeocodeLocation하면 오류가 발생할 수 있다.
                    self.lastLocationError = error //오류 객체 저장. 오류 없으면 nil
                    
                    if error == nil, let p = placemarks, !p.isEmpty { //에러 없고, placemarks가 비어있지 않은 경우 == reverseGeocodeLocation 변환 성공
                        self.placemark = p.last //일반적으로 반환한 배열에는 하나의 주소만 있지만, 2 개 이상의 주소가 있는 경우도 있다.
                    } else {
                        self.placemark = nil
                    }
                    
                    self.performingReverseGeocoding = false //flag
                    self.updateLabels()
                } //클로저 안에서 viewController의 프로퍼티와 메서드를 참조할 때 self 키워드를 써줘야 한다. 클로저는 값을 캡쳐하기 때문
            }
        } else if distance < 1 { //이전 위치와 크게 다르지 않을 경우 //정확히 0이 되는 경우가 드물다. 1보다 작은 소수점으로 수렴.
            let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp) //이전 위치 수신한 시간과 현재 위치 수신한 시간 차
            
            if timeInterval > 10 { //10초 이상 지속된 경우 중지
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
        }
    }
}

//GPS를 받아오는 일이 시간이 오래 걸릴 수 있는 일이므로 비동기로 작업하는 것이 좋다. //네트워크 연결, 다운로드 등
//비동기로 작업하지 않으면, GPS를 받아올 동안 앱에서 다른 작업을 할 수 없다.
//iOS에서는 1초 이상 걸리는 작업은 모두 비동기로 작업하는 것이 좋다.
//iOS는 watchdog timer가 있어 오랜 시간동안 앱이 작동하지 않으면, OS에서 앱을 강제로 종료시킨다.

//GPS가 내장되지 않은 디바이스, 통신 오류로 GPS를 받아오지 못하는 경우 등 여러 에러 상황을 염두에 둬야 한다.
//iPod touch는 내장 GPS가 없기 때문에 Wi-Fi로 위치를 파악한다.

//Info.plist에는 앱 실행을 위해 필요한 하드웨어를 설정하는 Required device capabilities가 있다.
//이 설정으로 App Store에서 지원하는 디바이스를 지정할 수 있다. //기본값은 iPhone 3GS 및 이후 모델의 CPU 아키텍처인 armv7
//이 앱의 경우 GPS를 필수 하드웨어로 지정할 수 있다. 그렇게 하면 GPS가 없는 iPod touch 등의 모델로는 App Store에서 다운 받을 수 없다.

//3.5 인치의 구형 iPhone은 iOS 11을 지원하지 않는다.

//Auto layout, Auto resizing
//Auto resizing이 더 간단하지만, 한계가 있다. Auto layout 이전에는 Auto resizing이 많이 쓰였다.
//Auto resizing는 super view의 크기가 변경될 때 어떻게 바뀌는 지 설정한다.
//super view의 4면에 고정되거나, 가로 세로를 조절한다.

//private API는 가급적 사용하지 않는 것이 좋다.
