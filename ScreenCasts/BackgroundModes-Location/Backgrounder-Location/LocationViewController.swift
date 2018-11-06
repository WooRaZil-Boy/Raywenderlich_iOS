/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import CoreLocation
import MapKit

class LocationViewController: UIViewController {
  @IBOutlet var mapView: MKMapView!
  
  fileprivate var locations = [MKPointAnnotation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //2. add an observer
    NotificationCenter.default.addObserver(self, selector: #selector(refreshMap), name: UIApplication.didBecomeActiveNotification, object: nil)
    //맵이 새로고침 될 때 옵저버를 추가한다.
  }
  
  //3. add deinit
  deinit {
    NotificationCenter.default.removeObserver(self)
    //ViewController가 메모리에서 해제될 때 옵저버를 해제한다.
  }
  
  private lazy var locationManager: CLLocationManager = {
    let manager = CLLocationManager()
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.delegate = self
    //1. request authorization
    manager.requestAlwaysAuthorization() //permission을 요청한다.
    if #available(iOS 9, *) {
      manager.allowsBackgroundLocationUpdates = true
    }
    return manager
  }()
  
  @IBAction func enabledChanged(_ sender: UISwitch) {
    if sender.isOn {
      locationManager.startUpdatingLocation()
    } else {
      locationManager.stopUpdatingLocation()
    }
  }
  
  @IBAction func accuracyChanged(_ sender: UISegmentedControl) {
    let accuracyValues = [
      kCLLocationAccuracyBestForNavigation,
      kCLLocationAccuracyBest,
      kCLLocationAccuracyNearestTenMeters,
      kCLLocationAccuracyHundredMeters,
      kCLLocationAccuracyKilometer,
      kCLLocationAccuracyThreeKilometers]
    
    locationManager.desiredAccuracy = accuracyValues[sender.selectedSegmentIndex];
  }
  
  @objc func refreshMap()
  {
    mapView.showAnnotations(self.locations, animated: true)
  }
}

// MARK: - CLLocationManagerDelegate
extension LocationViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let mostRecentLocation = locations.last else {
      return
    }
    
    // Add another annotation to the map.
    let annotation = MKPointAnnotation()
    annotation.coordinate = mostRecentLocation.coordinate
    
    // Also add to our map so we can remove old values later
    self.locations.append(annotation)
    
    // Remove values if the array is too big
    while locations.count > 100 {
      let annotationToRemove = self.locations.first!
      self.locations.remove(at: 0)
      
      // Also remove from the map
      mapView.removeAnnotation(annotationToRemove)
    }
    
    if UIApplication.shared.applicationState == .active {
      self.refreshMap()
    } else {
      print("App is backgrounded. New location is %@", mostRecentLocation)
    }
  }
}

//2010년, iOS 4부터 멀티 태스킹(background mode)가 지원되었다.
//배터리와 리소스 소모를 줄이기 위해 제한이 있으며, Capabilities에서 체크하지 않은 다른 기능을 background로 실행하는 경우 reject 될 수 있다.




//위치 추적을 하려면, info.plist에서 permission을 설정할때 text를 입력해 줘야 한다.
//Xcode Project에서 Capabilities 탭 - Background mode에서 활성화할 기능(Location updates)을 선택하면 된다.



