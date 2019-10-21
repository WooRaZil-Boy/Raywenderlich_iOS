//
//  TimeCounter.swift
//  RGBullsEye
//
//  Created by 근성가이 on 2019/10/21.
//  Copyright © 2019 근성가이. All rights reserved.
//

import Foundation
import Combine //Counter를 만드는데, Combine을 사용한다.

class TimeCounter: ObservableObject { //ObservableObject 프로토콜을 구현한다.
    let objectWillChange = PassthroughSubject<TimeCounter, Never>()
    //ObservableObject 프로토콜은 objectWillChange 속성을 구현해야 한다.
    //PassthroughSubject는 범용 Combine publisher 이다.
    //Timer Class의 Combine 게시자 TimerPublisher를 사용할 수도 있다.
    
    var timer: Timer?
    var counter = 0
    
    @objc func updateCounter() {
        counter += 1
        objectWillChange.send(self)
        //counter가 변경될 때 마다, objectWillChange는 subscriber에게 자신을 publish 한다.
    }
    
    init() {
        timer = Timer.scheduledTimer(timeInterval:1, target: self, selector:#selector(updateCounter), userInfo: nil, repeats:true)
        //매 초마다 updateCounter()를 호출하도록 타이머 초기화
    }
    
    func killTimer() { //타이머 제거
        timer?.invalidate()
        timer = nil
    }
}

//Observing a reference type object
//새로운 Asynchronous 프레임워크인 Combine으로 Counter를 생성한다.
//TimeCounter를 게시자(publisher)로 설정하면, ContentView(subscriber)가 구독자가 된다.
