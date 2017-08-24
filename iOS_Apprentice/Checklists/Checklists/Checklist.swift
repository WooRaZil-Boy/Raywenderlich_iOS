//
//  Checklist.swift
//  Checklists
//
//  Created by 근성가이 on 2016. 11. 1..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class Checklist: NSObject, NSCoding {
    var name = ""
    var items = [ChecklistItem]()
    var iconName: String
    
    convenience init(name: String) { //이 객체 내의 다른 이니셜라이저를 호출하는 것이라면 convenience 키워드를 붙여줘야 한다.
        self.init(name: name, iconName: "No Icon")
    }
    
    init(name: String, iconName: String) { //위의 이니셜라이저가 convenience라면 이 이니셜라이저는 designated initializer가 된다.
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        items = aDecoder.decodeObject(forKey: "Items") as! [ChecklistItem]
        iconName = aDecoder.decodeObject(forKey: "IconName") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(items, forKey: "Items")
        aCoder.encode(iconName, forKey: "IconName")
    }
}

extension Checklist {
    func countUncheckedItems() -> Int {
        return items.reduce(0) { cnt, item in cnt + (item.checked ? 0 : 1) } //첫 번째 파라미터인 cnt는 reduce 기본값. 여기서는 0. item은 배열이 가지고 있는 하나의 값.
    }
}








