//
//  CLLocationManager+Rx.swift
//  Wundercast
//
//  Created by 근성가이 on 2018. 4. 14..
//  Copyright © 2018년 Razeware LLC. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa

extension CLLocationManager: HasDelegate {
    //HasDelegate는 Rx에서 delegate가 있는 객체를 구현하는 방법
    public typealias Delegate = CLLocationManagerDelegate
}

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    //RxCLLocationManagerDelegateProxy는 observable을 생성하고 구독 직후 CLLocationManager에 연결하는 프록시
    //어떤 delegate를 이용할 지 정의해 준다.
    
    public weak private(set) var locationManager: CLLocationManager?

    public init(locationManager: ParentObject) { //초기화
        self.locationManager = locationManager
        super.init(parentObject: locationManager, delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() { //필수 메서드
        self.register { RxCLLocationManagerDelegateProxy(locationManager: $0) }
    }
}

extension Reactive where Base: CLLocationManager {
    public var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
        //delegate 설정
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:))) //원래의 delegate 설정과 연결해 준다.
            //methodInvoked(_ :)에 지정된 메서드가 호출될 때마다 다음 이벤트를 보내는 observable 반환
            //RxCocoa에 있는 Objective-C 코드 일부로, delegate 위한 low-level observer이다.
            //프록시로 사용된 delegate를 didUpdateLocations로 연결한다.
            .map { parameters in //수신된 데이터를 캐스팅해서 반환
                return parameters[1] as! [CLLocation]
            }
    }
}

//http://mrgamza.tistory.com/512

//RxCocoa는 UI 요소뿐만 아니라, 사용자 정의로 래핑해 줄 수 있다.
//Pods 내의 RxSwift 라이브러리의 Reactive.swift에
//Reactive<Base> 구조체, ReactiveCompatible 프로토콜이 있다.
//ReactiveCompatible의 extension에 rx 네임 스페이스를 만들수 있는 변수가 있다.
//NSObject를 확장해 ReactiveCompatible 프로토콜을 구현해 주면(빈 프로토콜. 추가만 하면 된다.) rx에서 사용할 수 있다.

//확장 클래스는 DelegateProxy를 delegate로 활용한다. CLLocationManager의 delegate를 대신해
//DelegateProxy로 수신된 모든 데이터를 각 observable로 delegate를 만든다(1:1 관계 매핑). p.266



