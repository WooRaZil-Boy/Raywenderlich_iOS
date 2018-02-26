//
//  MyImagePickerController.swift
//  MyLocations
//
//  Created by IndieCF on 2018. 2. 26..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class MyImagePickerController: UIImagePickerController { //이미지 피커 뷰에서 status 바의 색을 바꿔 준다.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
