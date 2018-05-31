/**
 * Copyright (c) 2018 Razeware LLC
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

import Foundation
import CoreLocation

protocol LocationManagerDelegate {
  func locationManager(_ locationManager: LocationManager, didEnterRegionId regionId: String)
  func locationManager(_ locationManager: LocationManager, didExitRegionId regionId: String)

  func locationManager(_ locationManager: LocationManager, didRangeBeacon beacon: CLBeacon)
  func locationManager(_ locationManager: LocationManager, didLeaveBeacon beacon: CLBeacon)
}

class LocationManager: NSObject {
  enum GeofencingError: Error {
    case notAuthorized
    case notSupported
  }

  var locationManager: CLLocationManager //Core Location의 CLLocationManager 클래스의 인스턴스
  var delegate: LocationManagerDelegate?
  var trackedLocation: CLLocationCoordinate2D?

  override init() {
    locationManager = CLLocationManager()
    super.init()
  }
    
    func initialize() {
        locationManager.delegate = self //delegate 설정
        locationManager.activityType = .otherNavigation //위치 추적 타입 설정
        //이 외에도 .fitness .automotiveNavigation .other가 있다.
        
        // Geofencing requires always authorization
        locationManager.requestAlwaysAuthorization() //네비게이션 권한 요청
        locationManager.startUpdatingLocation() //네비게이션 트래킹 시작
        //권한 부여가 되지 않았거나 거부된 경우 프로세스는 delegate를 통해 비동기적으로 수행되므로 해당 코드가 실행되지 않는다.
    }
    
    func startMonitoring(location: CLLocationCoordinate2D, radius: Double, identifier: String) throws {
        //throws로 오류가 발생하면 던진다.
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { throw GeofencingError.notSupported }
        //모니터링이 가능한 지 확인한다(지원하지 않는 디바이스인 경우).
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else { throw GeofencingError.notAuthorized }
        //사용자가 위치 추적 승인했는지 확인한다.
        
        trackedLocation = location
        
        let region = CLCircularRegion(center: location, radius: radius, identifier: identifier)
        //모니터링할 영역. center를 중심으로 radius 반경의 영역
        region.notifyOnEntry = true //해당 영역에 들어올 때 알린다.
        region.notifyOnExit = true //해당 영역을 벗어날 때 알린다.
        
        locationManager.startMonitoring(for: region) //모니터링을 시작한다.
        
        //단일 장치에서 최대 20개의 영역을 모니터링할 수 있다.
        
        // Delay state request by 1 second due to an old bug
        // http://www.openradar.me/16986842
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), qos: .default, flags: []) {
            //locationManager.requestState를 동기적으로 호출할 경우 버그가 있어 아무런 작동을 하지 않는다.
            self.locationManager.requestState(for: region)
            //delegate를 통해 비동기적으로 전달되는 해당 영역의 즉각적인 상태를 요청한다.
            //결과는 CLLocationManagerDelegate의 메서드(locationManager(_: didDetermineState: for:))를 통해 비동기적으로 전달된다.
        }
        
        //여기서 영역(resion)은 프로그램 리소를 공유한다. 따라서 CLLocationManager 인스턴스가 여러 개인 경우,
        //모니터링되는 영역에 출입할 때, 각 인스턴스에서 알림을 받게 된다.
        
        //모니터링을 시작한 이후에 requestState(for :)을 호출하는 이유는 디바이스가 이미 모니터링 중인 영역(region) 내에 있는지 여부를 알아야 하기 때문이다.
        //영역 모니터링은 상태가 변경된 경우에만 이벤트를 트리거한다(외부 -> 내부, 내부 -> 외부인 경우 뿐). 따라서 이미 외부 혹은 내부에 있을 때에는 이벤트가 일어나지 않는다.
        //디바이스가 이미 영역 안에 있다면 비컨을 사용해 작업해야 한다.
    }
    
    func stopMonitoringRegions() {
        trackedLocation = nil
        
        for region in locationManager.monitoredRegions {
            //모니터링 중인 영역은 monitoredRegions에 저장되어 있다.
            locationManager.stopMonitoring(for: region)
            //모든 영역의 모니터링을 중단한다. //추적 가능한 영역은 최대 20개
        }
    }
}

// MARK: - Beacons
extension LocationManager {
    func startMonitoring(beacons: [CLBeaconRegion]) {
        for beacon in beacons { //비콘 배열을 loop하면서
            startMonitoring(beacon: beacon) //모니터링 시작
        }
    }
    
    func startMonitoring(beacon: CLBeaconRegion) {
        guard CLLocationManager.isRangingAvailable() else {
            //앱이 실행중인 디바이스에서 비콘 기능을 사용할 수 있는 지 확인
            print("[ERROR] Beacon ranging is not available")
            return
        }
        
        locationManager.startMonitoring(for: beacon) //비콘을 지역을 모니터링한다.
        //식별자가 같은 경우 덮어쓴다.
    }
    
    func stopMonitoring(beacons: [CLBeaconRegion]) {
        for beacon in beacons { //비콘 배열을 loop하면서
            stopMonitoring(beacon: beacon) //모니터링 중단
        }
    }
    
    func stopMonitoring(beacon: CLBeaconRegion) {
        locationManager.stopRangingBeacons(in: beacon)
        //해당 지역에 속한 탐지 비콘을 중지한다.
        locationManager.stopMonitoring(for: beacon)
    }
    
    //Core Location에서 비콘을 탐지하는 것을 ranging라고 하며, 두 가지 단계가 있다.
    //• Entering the region : 해당 영역 ID에 속한 첫 번째 신호가 감지되면 발생한다.
    //  locationManager(_ : didEnterRegion :) delegate 메서드에서 처리된다.
    //• Ranging a single beacon : 개별 비콘이 경계를 이룰 때 발생한다.
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트 됐을 때. 새 위치를 사용할 수 있을 때 호출된다.
        guard let currentLocation = locations.last else { return }
        //locations에서 마지막 요소가 가장 최신의 위치 정보이다. //first가 가장 오래된 위치 정보
        guard let trackedLocation = trackedLocation else { return }
        
        let location = CLLocation(latitude: trackedLocation.latitude, longitude: trackedLocation.longitude)
        //저장해 놓은 CLLocationCoordinate2D 타입의 trackedLocation로 CLLocation를 생성한다.
        let distance = currentLocation.distance(from: location) //두 위치간 거리를 계산한다.
        
        print("Distance: \(distance)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //권한 상태가 notDetermined에서 다른 값(restricted, denied, authorizedAlways, authorizedWhenInUse)으로 변경될 때 호출된다.
        print("Authorization status changed to: \(status)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //위치를 가져오는 동안 오류가 발생하면 호출된다.
        //이 메서드를 구현하지 않으면 위치 서비스를 사용할 때 Core Location가 예외를 throw한다.
        print("Location manager failed with error: " + "\(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        //지정된 영역의 상태를 알려준다. Location Manager는 영역의 경계에 변화가 있을 때 마다 이 메서드를 호출한다.
        switch state {
        case .inside: //모니터링 중인 해당 영역 내에 있는 경우
            locationManager(manager, didEnterRegion: region) //진입 메서드 호출
        case .outside, .unknown: //진입 외의 경우
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        //영역 모니터링에 오류가 발생한 경우
        print("Geofencing monitoring failed for region " +
            "\(String(describing: region?.identifier))," +
            "error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //사용자가 지정된 영역으로 진입했을 때 호출된다.
        if let region = region as? CLBeaconRegion { //비콘이 감지되었을 때
            print("Entered in beacon region: \(region)")
            locationManager.startRangingBeacons(in: region)
            //지정된 비콘 영역에 대한 알림을 전달한다. //locationManager(_ : didRangeBeacons : in :) 으로 전달된다.
        } else {
            print("Entered in region: \(region)")
            delegate?.locationManager(self, didEnterRegionId: region.identifier)
            //LocationManagerDelegate의 메서드 호출(AdViewController 에서 해당 메서드가 구현된다).
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //사용자가 지정된 영역을 떠났을 때 호출된다.
        print("Left region \(region)")
        delegate?.locationManager(self, didExitRegionId: region.identifier)
    }
    
    // MARK: Beacons
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //비컨 영역 내에 하나 이상의 비컨들이 범위에 있을 때 호출된다.
        for beacon in beacons {
            delegate?.locationManager(self, didRangeBeacon: beacon)
            //LocationManagerDelegate로 전달한다(AdViewController).
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        //비콘 탐지(ranging)이 실패한 경우 호출된다.
        print("Beacon ranging failed for region \(region) with error: \(error.localizedDescription)")
    }
}

//Beacons
//비콘은 정기적으로 Bluetooth LE (low energy)로 신호를 내보내는 하드웨어이다.
//비콘의 신호는 3개의 정적 데이터 필드로 구성된다(Proximity UUID, Major, Minor).
//디바이스는 신호를 인식하며, 신호가 등록된 앱에 알림을 트리거할 수 있다.

//Detecting a beacon
//iOS에서 비콘은 Core Location에서 처리된다. 이는 발견하는 프로세스가 아니다. 따라서 Core Location에 통보하도록 요청할 필요 없다.
//대신 Core Location에 이미 알고 있는 신호를 모니터링하도록 한다.
//Core Location은 모니터링할 비콘을 지정하는 데 사용하는 CLBeaconRegion을 정의할 수 있다.
//여기에서 비콘 ID를 데이터로 바꿔서 사용한다. 동일한 ID를 재사용하기 보다는 UUID를 생성하는 것이 좋다.
