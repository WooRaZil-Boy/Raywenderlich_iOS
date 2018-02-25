//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by 근성가이 on 2018. 2. 26..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

extension UIImage {
    func resized(withBounds bounds: CGSize) -> UIImage { //bounds 사이즈만큼 이미지 축소/확대
        let horizontalRatio = bounds.width / size.width //변경 하려는 이미지 크기 가로 / 원본 이미지 크기 가로
        let verticalRatio = bounds.height / size.height //변경 하려는 이미지 크기 세로 / 원본 이미지 크기 세로
        let ratio = min(horizontalRatio, verticalRatio) //가로, 세로 중 작게 줄어드는 것을 기준으로
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        //단순히 bounds로 줄이는 것이 아니라, 가로 세로 비율 유지해 주기 위해 위의 작업이 필요하다.
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0) //그래픽 이미지 컨텍스트 시작 //비트맵 기반
        draw(in: CGRect(origin: CGPoint.zero, size: newSize)) //이미지 그리기
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() //현재 그래픽 이미지 컨텍스트 기반으로 이미지 반환
        UIGraphicsEndImageContext() //그래픽 이미지 컨텍스트 종료
        
        return newImage!
    }
}
