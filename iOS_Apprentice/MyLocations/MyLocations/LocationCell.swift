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

    override func awakeFromNib() { //스토리보드를 사용하는 객체는 awakeFromNib()메서드가 있다.
        //이 메서드는 UIKit이 스토리보드에서 객체를 로드할 때 호출된다. -> UI 커스텀 하기 좋은 위치.
        super.awakeFromNib()
        
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
        selectedBackgroundView = selection //selectedBackgroundView으로 선택된 셀의 컬러를 변경하는 듯한 효과를 얻을 수 있다.
        //셀을 탭할 때, 셀의 배경에 20% 투명도의 흰색 뷰가 배치된다.
        
        //Rounded corners for images
        photoImageView.layer.cornerRadius = photoImageView.bounds.size.width / 2 //절반씩 라운드 되서 원형
        photoImageView.clipsToBounds = true //true로 하면 모서리를 확인해(원형), 모서리의 바깥쪽으로 서브 뷰가 그려지지 않도록 한다.
        separatorInset = UIEdgeInsets(top: 0, left: 82, bottom: 0, right: 0) //셀 사이 구분선 inset
        //왼쪽에 inset을 넣어 오른쪽으로 이동. 이미지에 구분선 겹치지 않게 하기 위해서
        
//        descriptionLabel.backgroundColor = UIColor.purple
//        addressLabel.backgroundColor = UIColor.purple
        //오토 사이징이 제대로 되는지 확인해 보기 위해
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
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            
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
        
        return UIImage(named: "No Photo")! //따로 저장한 이미지 없다면 빈 placehoder 이미지 반환
    }
}
