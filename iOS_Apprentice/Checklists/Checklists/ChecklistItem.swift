//
//  ChecklistItem.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 17..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject { //초기화가 완료 되어야 한다.
    //Objective-C의 거의 모든 객체는 NSObject 기반. //NSObjectf를 상속하면 equatable이 구현되어 있는 상태.
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked //!는 logical not. 논리 값을 반대로 한다.
    }
    
    //좋은 객체 지향 설계 원칙은 객체가 자신의 상태를 변경하도록 해야한다는 것이다.
    //따라서 컨트롤러가 토글을 할 수도 있지만, ChecklistItem 자체를 토글을 하는 것이 낫다.
}
