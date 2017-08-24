//
//  JournalEntry+Helper.swift
//  SurfJournal
//
//  Created by 근성가이 on 2017. 1. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import Foundation
import CoreData

extension JournalEntry {
    func stringForDate() -> String {
        guard let date = date else { return "" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        return dateFormatter.string(from: date)
    }
    
    func csv() -> String {
        let coalescedHeight = height ?? ""
        let coalescedPeriod = period ?? ""
        let coalescedWind = wind ?? ""
        let coalescedLocation = location ?? ""
        let coalescedRating: String
        if let rating = rating?.int32Value {
            coalescedRating = String(rating)
        } else {
            coalescedRating = ""
        }
        
        return "\(stringForDate()),\(coalescedHeight),\(coalescedPeriod),\(coalescedWind),\(coalescedLocation),\(coalescedRating)\n"
    }
}
