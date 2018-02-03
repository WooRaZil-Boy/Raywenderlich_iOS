//
//  Checklist.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 2. 3..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class Checklist: NSObject {
    var name = ""
    
    init(name: String) {
        self.name = name //컴파일러가 혼동을 하기 때문에 이 경우에는 self를 반드시 써 줘야 한다.
        
        super.init()
    }
}
