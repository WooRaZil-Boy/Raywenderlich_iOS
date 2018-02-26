//
//  String+AddText.swift
//  MyLocations
//
//  Created by IndieCF on 2018. 2. 26..
//  Copyright © 2018년 근성가이. All rights reserved.
//

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") { //default 값 설정
        //메서드가 value type(구조체, 열거형) 내부의 속성 값을 변경하려면 mutating 키워드 필요
        //String은 구조체이므로 value type. 따라서 let으로 선언하면 값을 수정할 수 없다(reference type인 class는 let으로 선언해도 메모리 주소만 달라지지 않는 다면 가능).
        //따라서, mutating 키워드는 var로 선언된 value type에서만 사용할 수 있다.
        //reference type은 언제나 값을 변경시킬 수 있으므로 mutating 키워드가 따로 필요없다.
        if let text = text { //text가 nil이 아닌 경우
            if !isEmpty { //현재 문자열이 비어있지 않다면
                self += separator //separator 추가 후
            }
            self += text //해당 text 추가
        }
    }
}
