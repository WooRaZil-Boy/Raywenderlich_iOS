//
//  String+AddText.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 12. 6..
//  Copyright © 2016년 근성가이. All rights reserved.
//

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") { //구조체 내의 값을 메서드에서 직접 바꾸는 경우에는 mutating 키워드를 써줘야 한다. 써 주지 않을 시에는 상수로 처리되기 때문에 오류가 난다. String은 struct이다. class는 reference 타입이므로 let으로 선언한 변수일 지라도 항상 mutating이다.
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
