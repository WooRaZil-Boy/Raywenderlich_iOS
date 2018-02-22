//
//  LocationCell.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 22..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell { //Tag로 객체를 찾는 것 보다 UITableViewCell을 상속해 IBOutlet으로 연결하는 것이 더 객체지향적이고 나은 설계
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(for location: Location) { //셀 내부에서 일어나는 업데이트 이므로 이 곳에서 처리하는 것이 적절하다.
        //viewWithTag(_ :) 대신, 직접 셀의 속성을 사용한다.
        if location.locationDescription.isEmpty { //설명 없는 위치
            descriptionLabel.text = "(No Description)"
        } else {
            descriptionLabel.text = location.locationDescription
        }
        
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            
            if let s = placemark.locality {
                text += s
            }
            
            addressLabel.text = text
        } else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }
    }
}
