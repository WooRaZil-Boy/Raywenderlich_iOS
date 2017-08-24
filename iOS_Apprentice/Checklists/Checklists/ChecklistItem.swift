//
//  ChecklistItem.swift
//  Checklists
//
//  Created by 근성가이 on 2016. 10. 25..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation
import UserNotifications

class ChecklistItem: NSObject { //equatable 구현하기 위해 NSObject 필요. 여기서는 그냥 선언만 해 두면 됨
    var text = ""
    var checked = false
    var dueDate = Date()
    var shouldRemind = false
    var itemID: Int
    
    deinit { //삭제될 때 notification도 삭제
        removeNotification()
    }
    
    required init?(coder aDecoder: NSCoder) { //스토리보드가 NSCoding 사용하기 위해 필요하다. 디스크에 저장하고 읽기 위한 ChecklistItem
        text = aDecoder.decodeObject(forKey: "Text") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
        shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        itemID = aDecoder.decodeInteger(forKey: "ItemID")
        
        super.init()
    }
    
    override init() { //코드로 ChecklistItem 오브젝트 생성 시에 필요. add 눌러서 생성 시 등
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    func toggleChecked() {
        checked = !checked
    }
}

//MARK : - NSCoding
extension ChecklistItem: NSCoding { //NSKeyedArchiver가 인코딩이 가능하도록 NSCoding 필요
    func encode(with aCoder: NSCoder) { //필요한 값들을 인코딩. //NSKeyedArchiver이 ChecklistItem를 인코딩 하면 이 메서드가 불려짐.
        aCoder.encode(text, forKey: "Text") //Objective-C Framework이기 때문에 어떤 형이든 같은 메서드 사용 가능
        aCoder.encode(checked, forKey: "Checked")
        aCoder.encode(dueDate, forKey: "DueDate")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(itemID, forKey: "ItemID")
    }
}

//MARK: - Notifiaction
extension ChecklistItem {
    func scheduleNotification() {
        removeNotification()
        
        if shouldRemind && dueDate > Date() {
            let content = UNMutableNotificationContent() //notification 설정
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default()
            
            let calendar = Calendar(identifier: .gregorian) //그레고리안 달력
            let components = calendar.dateComponents([.month, .day, .hour, .minute], from: dueDate) //duedate에서 각각의 시간 정보를 가져와 저장
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false) //특정 날짜에 실행되는 Notification 트리거 설정 //UNTimeIntervalNotificationTrigger = 일정 시간 뒤에 트리거 실행
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger) //itemID을 키값으로
            let center = UNUserNotificationCenter.current()
            center.add(request)
            
            print("Scheduled notification \(request) for itemID \(itemID)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"]) //키 값으로 삭제
    }
}
