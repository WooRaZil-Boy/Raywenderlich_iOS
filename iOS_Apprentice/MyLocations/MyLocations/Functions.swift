//
//  Functions.swift
//  MyLocations
//
//  Created by 근성가이 on 2016. 11. 30..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import Foundation
import Dispatch //Grand Central Dispatch

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) { //파라미터로 클로저 쓰는 경우. @escaping 속성은 '이 클로져가 어딘가 저장되거나 나중에 호출 될 수 있게 메소드 등에 전달되는 용도로 사용될 수 있다' 라는 의미로 보자. 위의 경우는 디스패치 큐를 통해서 다른 스레드에서 별도로 클로져가 실행되는 환경이기에 escaping 이 필요하다. //반대로 클로져가 다른 변수로 전달되는게 아니라 해당 메소드 내에서 호출되고 마는 경우라면 별도의 escaping 에 대한 속성은 필요없다. 앞 서 이야기 했지만 기본적으로 @noescape 가 기본 속성이기 때문이다.    
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

let applicationDocumentsDirectory: URL = { //전역 변수는 Lazy로 취급된다.
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    return paths[0]
}()

let MyManagedObjectContextSaveDidFailNotification = Notification.Name("MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil) //모든 객체가 주고 받을 수 있다. 받는 객체와 보내는 객체 모두 상대 객체를 알지 못해도 상관없다.
}
