//
//  ImageViewCard.swift
//  ImageGallery
//
//  Created by 근성가이 on 2017. 1. 21..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class ImageViewCard: UIImageView {
    
    //MARK : - Properties
    var title: String!
    var didSelect: ((ImageViewCard) -> ())?
    
    convenience init(imageNamed: String, title name: String) {
        self.init()
        
        image = UIImage(named: imageNamed)
        contentMode = .scaleAspectFill
        clipsToBounds = true //하위 뷰를 뷰의 경계로 제한할지 여부. //true로 설정하면 하위보기의 범위가 제한된다. //false로 설정하면 프레임 범위를 벗어나는 서브 뷰는 잘리지 않는다. (false가 기본값)
        
        title = name
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
        layer.shouldRasterize = true //캐싱
        layer.rasterizationScale = UIScreen.main.scale //캐싱 범위 설정
    }
    
    override func didMoveToSuperview() { //상위 뷰가 변경될 때 하위 뷰가 재정의할 필요가 있을 때
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ImageViewCard.didTapHandler(_:))))
    }
    
    func didTapHandler(_ tap: UITapGestureRecognizer) {
        didSelect?(self)
    }
}
