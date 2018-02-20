//
//  Functions.swift
//  MyLocations
//
//  Created by IndieCF on 2018. 2. 19..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) { //() -> Void 타입의 클로저 //() -> (), Void -> Void와 같다.
    //@escaping은 즉시 실행되지 않는 클로저에 필요하다. 이 키워드로 해당 클로저를 유지해야 한다고 전달해 준다.
    //@escaping로 함수가 반환된 이후에 실행되는 경우 표시해 준다. (여기서는 seconds 뒤에 클로저가 실행되고, 해당 함수가 먼저 반환된다.)
    //위의 경우, 함수가 반환되어도 해당 클로저는 어딘가에서 실행이 되어야 하기 때문에 @escaping 키워드가 필요하다.
    //Swift 1, 2에서는 escaping이 기본 속성이었고, @noescape를 선택적으로 붙여줘야 했다.
    //Swift 3 부터 반대로 @noescape이 기본 속성이 되었다. @noescape는 클로저가 함수를 벗어나지 않기 때문에 컴파일러가 최적화할 수 있다.
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run) //Grand Central Dispatch(GCD)로 비동기 작업을 설정한다.
    //현재시간에서 deadline 뒤에 클로저 내의 코드가 실행된다.
} //free function으로 어디에서나 접근할 수 있다.
//직접 GCD 코드를 써도 되지만, 이런 식으로 정리하면 추상화를 쉽게 구현할 수 있다.

let applicationDocumentsDirectory: URL = { //global constant, 전역 상수 : 너무 자주 사용하지는 않는 것이 좋다.
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    //샌드박스의 경로
    
    return paths[0]
} ()

let CoreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification") //새로운 알림 정의

func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: CoreDataSaveFailedNotification, object: nil)
    //NotificationCenter로 알림 게시. 앱의 모든 객체는 알림을 게시할 수 있다(여기서는 object: nil).
    //알림이 실행되면 NotificationCenter는 특정 메서드를 호출한다.
    //UIKit에도 여러 알림이 있다(ex. 홈 버튼 누를 때 일시 정지 될 것을 알려주는 알림)
    //delegate처럼 객체가 서로 상호작용할 수 있는 또 다른 방법 - 알림을 보내는 객체와 받는 객체는 서로에 대해 알 필요 없다.
    //여기에서 NotificationCenter를 사용하는 이유는 Core Data가 신경 쓸 부분을 덜어낼 수 있다.
    //오류가 발생할 때 앱의 어느 지정에서 fatalCoreDataError(_ :) 함수로 알림을 보내고 다른 객체가 알림을 수신해 오류 처리하기 때문.
}
