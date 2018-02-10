//
//  ChecklistItem.swift
//  Checklists
//
//  Created by 근성가이 on 2018. 1. 17..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import Foundation
import UserNotifications

//Codable은 Encodable와 Decodable의 두 가지 프로토콜로 구성되어 있다. 직렬화를 위해 구현하는 프로토콜
//대부분의 Swift 기본 객체는 기본적으로 Codable을 구현해 놨다.
//ChecklistItem의 변수들이 모두 스위프트 기본형이므로, Codable을 추가하기만 하면 따로 코드를 추가할 필요 없다.
//객체 지향 프로그래밍의 원칙 중 하나는 객체가 가능한 한 많은 일을 해야한다는 것이다.

class ChecklistItem: NSObject, Codable { //초기화가 완료 되어야 한다.
    //Objective-C의 거의 모든 객체는 NSObject 기반. //NSObjectf를 상속하면 equatable이 구현되어 있는 상태.
    var text = ""
    var checked = false
    
    //Notification을 위한 변수
    var dueDate = Date()
    var shouldRemind = false
    var itemID: Int //그냥 id는 Objective-C의 키워드이기 때문에 그대로 사용하는 경우 충돌이 날 수 있으므로 가급적 피해준다.
    
    override init() {
        itemID = DataModel.nextChecklistItemID() //새로 추가된 변수들이 초기화 된 후에
        super.init() //super.init를 실행해야 한다.
    }
    
    deinit { //ChecklistItem이 메모리에서 해제 될 때 Notification도 삭제
        removeNotification()
    }
    
    func toggleChecked() { //좋은 객체 지향 설계 원칙은 객체가 자신의 상태를 변경하도록 해야한다는 것이다.
        //따라서 컨트롤러가 토글을 할 수도 있지만, ChecklistItem 자체를 토글을 하는 것이 낫다.
        checked = !checked //!는 logical not. 논리 값을 반대로 한다.
    }
    
    func scheduleNotification() {
        removeNotification() //이전 Notification이 있으면 삭제. shouldRemind를 false로 한 경우에도 삭제.
        
        if shouldRemind && dueDate > Date() { //알람 설정 되어 있고, 설정 시간이 현재 시간보다 미래이면
            //Notification 알림 생성
            let content = UNMutableNotificationContent()
            content.title = "Reminder:"
            content.body = text
            content.sound = UNNotificationSound.default()
            
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.month, .day, .hour, .minute], from: dueDate) //dueDate에서 월, 일, 시, 분 추출
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false) //지정된 시간에 알림 트리거 설정
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger) //알림 리퀘스트 설정
            //itemID를 String으로 변환해서 id로 설정. 후에 취소해야 할 경우를 대비해서.
            
            let center = UNUserNotificationCenter.current()
            center.add(request) //UNUserNotificationCenter에 알림 리퀘스트 등록
            
            print("Scheduled: \(request) for itemID: \(itemID)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"]) //itemID로 notification 삭제
    }
} //모든 변수가 초기화되서 생성되므로 따로 init를 쓸 필요 없다.
