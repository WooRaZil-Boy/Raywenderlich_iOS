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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude) //8자리까지 표시
            //Format Strings :: 정수 : %d, 부동소수점 : %f, 객체 : %@. Objective-C에서 흔한 표현
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude) //8자리까지 표시
            tagButton.isHidden = false
            messageLabel.text = ""
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location' to Start"
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
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //정확도 최대 10미터
        locationManager.startUpdatingLocation() //startUpdatingLocation()으로 좌표를 받아와야 사용 가능하다.
        //startUpdatingLocation()을 시작하면 멈춤 지시가 따로 있을 때까지 계속해서 GPS 정보를 업데이트 하며, 정확도가 향상된다.
    }
}

//MARK: - CLLocationManagerDelegate
extension CurrentLocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //Error 객체에는 도메인, 코드가 있다. //여기서 도메인은 kCLErrorDomain, 코드는 CLError.denied로 식별
        //k 접두사는 상수를 나타낼 때 흔히 썼었다.
        print("didFailWithError \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //위도와 경도 좌표를 포함하는 CLLocation 객체의 배열을 제공. //고도, 속도 등 다른 정보도 제공
        let newLocation = locations.last! //startUpdatingLocation()로 정보를 받아오면 계속해서 정보가 업데이트 되면서 배열에 추가 되기 때문에, 최근 정보(배열의 마지막 객체)를 가져와야 한다.
        print("didUpdateLocations \(newLocation)")
        
        location = newLocation
        updateLabels()
    }
}

//GPS를 받아오는 일이 시간이 오래 걸릴 수 있는 일이므로 비동기로 작업하는 것이 좋다. //네트워크 연결, 다운로드 등
//비동기로 작업하지 않으면, GPS를 받아올 동안 앱에서 다른 작업을 할 수 없다.
//iOS에서는 1초 이상 걸리는 작업은 모두 비동기로 작업하는 것이 좋다.
//iOS는 watchdog timer가 있어 오랜 시간동안 앱이 작동하지 않으면, OS에서 앱을 강제로 종료시킨다.
