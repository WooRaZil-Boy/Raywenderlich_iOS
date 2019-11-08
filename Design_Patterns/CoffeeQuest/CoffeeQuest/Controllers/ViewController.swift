/// Copyright (c) 2019 Razeware LLC
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

import MapKit
import YelpAPI

public class ViewController: UIViewController {
  
  // MARK: - Properties
  private var businesses: [YLPBusiness] = []
  private let client = YLPClient(apiKey: YelpAPIKey)
  private let locationManager = CLLocationManager()
  public let annotationFactory = AnnotationFactory() //Factory Pattern
  
  // MARK: - Outlets
  @IBOutlet public var mapView: MKMapView! {
    didSet {
      mapView.showsUserLocation = true
    }
  }
  
  // MARK: - View Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()

    locationManager.requestWhenInUseAuthorization()
  }
  
  // MARK: - Actions
  @IBAction func businessFilterToggleChanged(_ sender: UISwitch) {
    
  }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
  
  public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    centerMap(on: userLocation.coordinate)
  }
  
  private func centerMap(on coordinate: CLLocationCoordinate2D) {
    let regionRadius: CLLocationDistance = 3000
    let coordinateRegion = MKCoordinateRegion(center: coordinate,
                                              latitudinalMeters: regionRadius,
                                              longitudinalMeters: regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
    searchForBusinesses()
  }
  
  private func searchForBusinesses() {
    let coordinate = mapView.userLocation.coordinate
    guard coordinate.latitude != 0,
      coordinate.longitude != 0 else {
        return
    }
    
    let yelpCoordinate = YLPCoordinate(latitude: coordinate.latitude,
                                       longitude: coordinate.longitude)
    
    client.search(with: yelpCoordinate,
                  term: "coffee",
                  limit: 35,
                  offset: 0,
                  sort: .bestMatched) { [weak self] (searchResult, error) in
                    guard let self = self else { return }
                    guard let searchResult = searchResult,
                      error == nil else {
                        print("Search failed: \(String(describing: error))")
                        return
                    }
                    self.businesses = searchResult.businesses
                    DispatchQueue.main.async {
                      self.addAnnotations()
                    }
    }
  }
  
//  private func addAnnotations() {
//    for business in businesses {
//      guard let yelpCoordinate = business.location.coordinate else {
//        continue
//      }
//
//      let coordinate = CLLocationCoordinate2D(latitude: yelpCoordinate.latitude,
//                                              longitude: yelpCoordinate.longitude)
//      let name = business.name
//      let rating = business.rating
//      let image: UIImage
//
//      switch rating {
//      case 0.0..<3.5:
//        image = UIImage(named: "bad")!
//      case 3.5..<4.0:
//        image = UIImage(named: "meh")!
//      case 4.0..<4.75:
//        image = UIImage(named: "good")!
//      case 4.75...5.0: //... 는 <=
//        image = UIImage(named: "great")!
//      default:
//        image = UIImage(named: "bad")!
//      }
//
//
//      let annotation = BusinessMapViewModel(coordinate: coordinate,
//                              name: name,
//                              rating: rating,
//                              image: image)
//      mapView.addAnnotation(annotation)
//    }
//  }
  
  
  
  
  private func addAnnotations() {
    for business in businesses {
      guard let viewModel = annotationFactory.createBusinessMapViewModel(for: business) else {
        continue
      }
      mapView.addAnnotation(viewModel)
    }
  }
  //Factory Pattern으로 변경
  
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let viewModel = annotation as? BusinessMapViewModel else {
          return nil
    }
    
    let identifier = "business"
    let annotationView: MKAnnotationView
    if let existingView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
      annotationView = existingView
    } else {
      annotationView = MKAnnotationView(annotation: viewModel, reuseIdentifier: identifier)
    }
    
    annotationView.image = viewModel.image
    annotationView.canShowCallout = true
    
    return annotationView
  }
}

//Chapter 10: Model-View-ViewModel Pattern

//Tutorial project
//Debug ▸ Location에서 시뮬레이터 위치를 바꿀 수 있다.
//지도에서 기본 pin으로 yelp에 등록된 카페를 보여준다. 여기에 카페의 상호명, 평점 등을 표시해 주도록 한다.
//MapPin.swift에서 설정을 추가해 준다. 여기서 coordinate, title, rating 등의 data로
//Map에 표시할 수 있는 view 로 변환해 준다. 따라서 MapPin은 View Model 역할을 한다.
//역할이 바꼈으므로 적절한 이름으로 변경해 준다.
//MapPin을 마우스 우클릭 한 후, Refactor ▸ Rename을 선택한다.
//BusinessMapViewModel으로 이름을 변경해 준다.
//Models Group도 ViewModels으로 이름을 변경해 준다.
//다음, 기본 MapPin보다 더 다양한 속성을 표시하기 위해 코드를 추가한다.
//image, ratingDescription 속성을 추가해 준다.
//기본 핀 대신 이미지를 사용하여 사용자가 annotation을 누를 때마다 ratingDescription을 표시한다.
//생성자에서도 해당 속성을 초기화 시켜 준다.
//ViewController의 addAnnotations에서 추가한 속성에 대한 설정을 업데이트 해 준다.
//하지만, build 후 실행해 봐도 아무런 변화가 없다. 지도는 image에 대해 알지 못하기 때문이다.
//custom pin의 annotation image를 제공하기 위해 delegate method를 재정의해야 한다.
//mapView(_: viewFor:)를 재정의한다.
//------------------------------------------------------------------------------------




//Chapter 11: Factory Pattern

//Tutorial project
//Factory Pattern을 사용하여 Yelp 등급에 따라 아이콘 바꾸는 메커니즘을 개선한다.
//Factories라는 새 그룹을 작성하고, AnnotationFactory.swift를 생성한다.
//이전 MVVM 패턴을 구현하면서, addAnnotations()에서 구현한 코드와 비슷하다.
//이렇게 Factory Pattern을 구현하면, 변환 로직이 한 곳에 포함되므로 유지 보수성이 좋아진다.
//------------------------------------------------------------------------------------

