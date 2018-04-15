//
//  MKMapView+Rx.swift
//  Wundercast
//
//  Created by 근성가이 on 2018. 4. 15..
//  Copyright © 2018년 Razeware LLC. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    public weak private(set) var mapView: MKMapView? //프록시 사용 위한 참조 생성
    
    public init(mapView: ParentObject) { //초기화
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() { //등록
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

extension Reactive where Base: MKMapView {
    public var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
        //delegate 설정
    }
    
    public func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        return RxMKMapViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
        //installForwardDelegate로 반환 유형이 필요한 delegate 프로토콜을 구현해 줄 수 있다.
        //호출을 전달하고 필요한 경우 반환 값이 있는 Rx로 래핑되지 않은 delegate 메서드를 전달한다.
    }
    
    var overlays: Binder<[MKOverlay]> { //오버레이 처리
        return Binder(self.base) { mapView, overlays in
            //Binder로 bind나 drive를 사용할 수 있다.
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlays(overlays)
            //MKOverlay의 인스턴스를 가져와 맵에 표시한다.
            //여기에서는 전부 삭제하고 다시 추가한다.
            //앱이 더 커진다면 필요한 부분만 업데이트하도록 리팩토링해야 한다(diff algorithm).
        }
    }
    
    public var regionDidChangeAnimated: ControlEvent<Bool> {
        //지도에서 사용자가 드래그 등의 이벤트를 했을 때 수신한다.
        let source = delegate
            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            //delegate의 mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool)에서
            //해당 이벤트가 발생한 경우를 가져올 수 있다.
            //메서드를 할당해 준다.
            .map { parameters in
                return (parameters[1] as? Bool) ?? false //캐스팅 실패한 경우 false
            }
        
        return ControlEvent(events: source)
    }
}

//CLLocationManager의 extension과 같은 패턴이다.
//RxMKMapViewDelegateProxy를 만들고
//기본 MKMapView 클래스에 대해 Reactive를 확장한다.


