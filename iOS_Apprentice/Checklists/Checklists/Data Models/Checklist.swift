//
//  Checklist.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 2. 3..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

//Codable은 Encodable와 Decodable의 두 가지 프로토콜로 구성되어 있다. 직렬화를 위해 구현하는 프로토콜
//대부분의 Swift 기본 객체는 기본적으로 Codable을 구현해 놨다.
//ChecklistItem의 변수들이 모두 스위프트 기본형이므로, Codable을 추가하기만 하면 따로 코드를 추가할 필요 없다.

class Checklist: NSObject, Codable {
    var name = ""
    var iconName = "No Icon"
    var items = [ChecklistItem]() //var items: [ChecklistItem] = []과 같다.
    
//    var items = [ChecklistItem]() //배열 생성. 배열 안에 값은 없다.
//    var items: [ChecklistItem] //배열 선언. 생성한 것은 아니다.
    
    init(name: String, iconName: String = "No Icon") { //default 값 설정
        self.name = name //컴파일러가 혼동을 하기 때문에 이 경우에는 self를 반드시 써 줘야 한다.
        self.iconName = iconName
        
        super.init()
    }
    
    func countUncheckedItems() -> Int { //functional programming으로 짧게 처리할 수 있다.
        return items.reduce(0) { cnt, item in cnt + (item.checked ? 0: 1) } //삼항 연산자 (앞의 조건이 참이면 0, 아니면 1)
        //초기값이 0. 처음 cnt 변수에는 0이 들어 있지만, 이후 0이나 1을 계속 더해간다.
    }
}
