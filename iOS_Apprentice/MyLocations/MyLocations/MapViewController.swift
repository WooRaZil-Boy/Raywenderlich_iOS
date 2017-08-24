//
//  MapViewController.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 12. 4..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext! {
        didSet { //Appdelegate에서 값을 할당하면 managedObjectContext에 값이 바뀌면서 옵저버를 추가한다.
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { notification in //CoreData의 내용이 바뀌면 mapView의 annotaion 업데이트
                if self.isViewLoaded {
                
                    //이런 식으로 필요한 것만 찾아서 다시 로드하는 것이 더 효율적이다.
//                    if let dictionary = notification.userInfo {
//                        print(dictionary["inserted"])
//                        print(dictionary["deleted"])
//                        print(dictionary["updated"])
//                    }
                    
                    self.updateLocations() //annotation이 많아지면 비효율적
                }
            }
        }
    }
    var locations = [Location]()
}

extension MapViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        
        if  !locations.isEmpty {
            showLocations()
        }
    }
}

extension MapViewController {
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000) //1000미터 x 1000미터
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    func updateLocations() { //managedObjectContext 사용하면 더 쉽게 할 수 있다.
        mapView.removeAnnotations(locations) //맵뷰에 annoation을 남기거나 지우기 위해서는 MKAnnotation 프로토콜이 구현되어야 한다.
        
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest) //try! 를 쓸 경우 do - try - catch를 쓸 필요 없지만, 오류가 날 경우 바로 crash
        mapView.addAnnotations(locations)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion { //annotaions의 중간 값으로 위치
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0: //저장된 위치가 하나도 없을 때 유저의 현재 위치
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1: //저장된 위치가 하나 일 때 하나의 위치
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
        default: //저장된 위치가 둘 이상일 때 그 중간 위치
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude,annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mapView.regionThatFits(region)
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Location else {
            return nil
        }
        
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) //annotation 재사용 //tableView랑 비슷
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.tintColor = UIColor(white: 0.0, alpha: 0.5) //핀 뷰(구름 창)
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1) //핀 꼭지
            
            let rightButton = UIButton(type: .detailDisclosure) //annotation에 버튼 추가
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton
            
            annotationView = pinView
        }
        
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        
        return annotationView
    }
    
    func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }
}

//MARK: - Navigations
extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
}

//MARK: - UINavigationBarDelegate
extension MapViewController: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition { //Navigation Bar 위치 
        return .topAttached
    }
}
