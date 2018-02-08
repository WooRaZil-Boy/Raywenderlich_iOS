//
//  ChecklistItem.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 17..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import Foundation

//Codable은 Encodable와 Decodable의 두 가지 프로토콜로 구성되어 있다. 직렬화를 위해 구현하는 프로토콜
//대부분의 Swift 기본 객체는 기본적으로 Codable을 구현해 놨다.
//ChecklistItem의 변수들이 모두 스위프트 기본형이므로, Codable을 추가하기만 하면 따로 코드를 추가할 필요 없다.

class ChecklistItem: NSObject, Codable { //초기화가 완료 되어야 한다.
    //Objective-C의 거의 모든 객체는 NSObject 기반. //NSObjectf를 상속하면 equatable이 구현되어 있는 상태.
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked //!는 logical not. 논리 값을 반대로 한다.
    }
    
    //좋은 객체 지향 설계 원칙은 객체가 자신의 상태를 변경하도록 해야한다는 것이다.
    //따라서 컨트롤러가 토글을 할 수도 있지만, ChecklistItem 자체를 토글을 하는 것이 낫다.
} //모든 변수가 초기화되서 생성되므로 따로 init를 쓸 필요 없다.
