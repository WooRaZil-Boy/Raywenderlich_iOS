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
    @IBOutlet weak var photoImageView: UIImageView!

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
        
        photoImageView.image = thumbnail(for: location)
    }
    
    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage { //이미지를 가지고 있고, 옵셔널 해제가 된다면
            //if location.hasPhoto && let image = location.photoImage :: Bool형이 아니라 논리연산 할 수 없으므로 이렇게 쓰면 안 된다.
            return image.resized(withBounds: CGSize(width: 52, height: 52)) //이미지 반환
            //썸네일에도 이미지 원본을 가져오면 메모리가 낭비되기 때문에 적당하게 줄인다.
            //52 * 52로 지정했지만, 원본 이미지가 정사각형이 아닌 경우 더 작을수 있어 스토리보드에서 Content Mode를 적절히 바꿔줘야 한다.
            //Aspect Fit은 긴 쪽으로 scale, Aspect Fill은 짧은 쪽으로 scale(가로, 세로 비율은 유지).
        }
        
        return UIImage() //따로 저장한 이미지 없다면 빈 placehoder 이미지 반환
    }
}
