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
import MapKit
import CoreLocation

class GeotificationsViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  private var locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    GeotificationManager.shared.geotifications.forEach {
      addToMap($0)
    }
  }
  
  // MARK: - Segues
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "addGeotification" {
      guard let addViewController = segue.destination as? AddGeotificationViewController else { return }
      addViewController.delegate = self
    }
  }
  
  @IBAction func listExit(segue: UIStoryboardSegue) {
    mapView.removeAnnotations(mapView.annotations)
    GeotificationManager.shared.geotifications.forEach {
      addToMap($0)
    }
    if GeotificationManager.shared.geotifications.isEmpty {
      updateGeotificationsCount()
    }
  }
  
  // MARK: Functions that update the model/associated views with geotification changes
  func add(_ geotification: Geotification) {
    GeotificationManager.shared.geotifications.append(geotification)
    addToMap(geotification)
  }
  
  private func addToMap(_ geotification: Geotification) {
    mapView.addAnnotation(geotification)
    addRadiusOverlay(forGeotification: geotification)
    updateGeotificationsCount()
  }
  
  func remove(_ geotification: Geotification) {
    GeotificationManager.shared.remove(geotification)
    mapView.removeAnnotation(geotification)
    removeRadiusOverlay(forGeotification: geotification)
    updateGeotificationsCount()
  }
  
  private func updateGeotificationsCount() {
    let count = GeotificationManager.shared.geotifications.count
    title = "Geotifications: \(count)"
    navigationItem.rightBarButtonItem?.isEnabled = (count < 20)
  }
  
  // MARK: Map overlay functions
  private func addRadiusOverlay(forGeotification geotification: Geotification) {
    mapView?.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
  }
  
  private func removeRadiusOverlay(forGeotification geotification: Geotification) {
    // Find exactly one overlay which has the same coordinates & radius to remove
    guard let overlays = mapView?.overlays else { return }
    for overlay in overlays {
      guard let circleOverlay = overlay as? MKCircle else { continue }
      let coord = circleOverlay.coordinate
      if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
        mapView?.removeOverlay(circleOverlay)
        break
      }
    }
  }
  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  }
}

// MARK: - Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapView.showsUserLocation = status == .authorizedAlways
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }
}

// MARK: - MapView Delegate
extension GeotificationsViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "myGeotification"
    if annotation is Geotification {
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        let removeButton = UIButton(type: .custom)
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
        annotationView?.leftCalloutAccessoryView = removeButton
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        if let annotationView = annotationView, traitCollection.forceTouchCapability == .available {
          //3D Touch가 사용가능한지, 먼저 확인해야 한다.
          registerForPreviewing(with: self, sourceView: annotationView)
          //디바이스가 3D Touch를 지원한다면, registerForPreviewing(with:sourceView:)를 호출해 3D Touch를 추가해 줄 수 있다.
          //3D Touch를 사용할 때 annotationView가 Peek 제스처(미리보기)의 source가 된다.
        }
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
    return nil
  }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKCircle {
      let circleRenderer = MKCircleRenderer(overlay: overlay)
      circleRenderer.lineWidth = 1.0
      circleRenderer.strokeColor = .purple
      circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
      return circleRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    // Delete geotification
    if control == view.rightCalloutAccessoryView {
      guard let annotation = view.annotation as? Geotification,
        let addGeotificationViewController = storyboard?.instantiateViewController(withIdentifier: "AddGeotificationViewController") as? AddGeotificationViewController else { return }
      addGeotificationViewController.geotification = annotation
      addGeotificationViewController.delegate = self
      navigationController?.show(addGeotificationViewController, sender: nil)
    } else {
      let geotification = view.annotation as! Geotification
      remove(geotification)
    }
  }
}

// MARK: AddGeotificationsViewControllerDelegate
extension GeotificationsViewController: AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didAdd geotification: Geotification) {
    navigationController?.popViewController(animated: true)
    GeotificationManager.shared.add(geotification)
    addToMap(geotification)
  }
  
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didChange oldGeotifcation: Geotification, to newGeotification: Geotification) {
    navigationController?.popViewController(animated: true)
    remove(oldGeotifcation)
    GeotificationManager.shared.add(newGeotification)
    addToMap(newGeotification)
  }
  
  func addGeotificationViewController(_ controller: AddGeotificationViewController,
                                      didSelect action: UIPreviewAction,
                                      for previewedController: UIViewController) {
    //Preview의 Action을 처리한다.
    switch action.title {
    case "Edit":
      navigationController?.show(previewedController, sender: nil)
    case "Delete":
      guard let addGeotificationViewController = previewedController as? AddGeotificationViewController,
        let geotification = addGeotificationViewController.geotification else { return }
      remove(geotification)
    default:
      break
    }
  }
}

//Apple이 iPhone 6S와 함께 3D Touch를 도입한 이후 사용자는 새로운 터치 기반 상호 작용으로 앱 내 기능에 액세스할 수 있다.
//ex. 길게 눌러(Peek) 페이지를 미리본 후, pop 해서 해제할 수 있다.
//3D Touch로 더 몰입적이고 전문적인 경험을 제공할 수 있다.
//3D Touch는 스토리보드와 코드로 모두 구현할 수 있다. 시뮬레이터 보다는 실제 디바이스로 테스트 해 보는 것이 좋다.




//Adding Peek and Pop
//스토리보드에서 해당 세그의 Peek & Pop를 활성화 해 준다(Preview & Commit Segues).
//해당 segue를 활성화하는 부분을 3D Touch(Long Tap에서 강하게 눌러 주면 된다)하면 Peek & Pop이 활성화 된다.




//Custom Handling
//Interface Builder를 사용하지 않는 상황에서도 코드로 3D Touch를 추가해 줄 수 있다.

// MARK: - UIViewController Previewing Delegate
extension GeotificationsViewController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    //3D Touch의 preview controller를 구성하기 위한 인터페이스를 정의한다.
    //mapView(_:viewFor:)에서 annotation view에 3D Touch를 적용했으므로, Peeks and Pops 동안에 표시될 viewController를 지정해 줘야 한다.
    guard let annotationView = previewingContext.sourceView as? MKPinAnnotationView,
    let annotation = annotationView.annotation as? Geotification,
      let addGeotificationViewController = storyboard?.instantiateViewController(withIdentifier: "AddGeotificationViewController") as? AddGeotificationViewController else { return nil }
    //previewingContext는 Touch source에 대한 액세스를 제공한다. source View가 여러 개인 경우, 해당하는 view를 찾을 수 있다.
    
    addGeotificationViewController.geotification = annotation //객체 전달
    addGeotificationViewController.delegate = self //delegate 설정
    
    addGeotificationViewController.preferredContentSize = CGSize(width: 0, height: 360)
    //preview는 default로 디바이스 전체를 채운다. 전체 표시될 경우, 공백이 있으므로 preferredContentSize를 조절해 준다.
    //preferredContentSize의 값은 주로 popover되는 ViewController의 내용을 표시할 때 크기를 지정해 주기 위해 사용된다.
    
    return addGeotificationViewController
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    //3D Touch의 preview controller를 구성하기 위한 인터페이스를 정의한다.
    //Peek이 Pop될 위치에 대한 정보를 제공해줘야 한다. preview로 이동하는 방법을 처리한다.
    navigationController?.show(viewControllerToCommit, sender: nil)
    //navigation stack에 push해 준다.
  }
}

