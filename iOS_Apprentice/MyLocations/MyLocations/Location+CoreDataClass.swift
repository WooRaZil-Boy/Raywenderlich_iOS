//
//  Location+CoreDataClass.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 12. 1..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Location: NSManagedObject, MKAnnotation { //맵 뷰에서 annotation을 사용하기 위해 MKAnnotation 추가
    var coordinate: CLLocationCoordinate2D { //read-only computed properties
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { //read-only computed properties //맵뷰 annotaion 타이틀
        if locationDescription.isEmpty {
            return "(No Description)"
        } else {
            return locationDescription
        }
    }
    
    var subtitle: String? { //read-only computed properties //맵뷰 annotaion 서브 타이틀
        return category
    }
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set") //nil이면 crash
        let filename = "Photo-\(photoID!.intValue).jpg"
        
        return applicationDocumentsDirectory.appendingPathComponent(filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID")
        userDefaults.set(currentID + 1, forKey: "PhotoID")
        userDefaults.synchronize()
        
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
}
