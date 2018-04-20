//
//  ViewController.swift
//  Gesture
//
//  Created by 근성가이 on 2018. 4. 19..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture

class ViewController: UIViewController {
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.rx
            .tapGesture() //각 해당 제스처 붙여서 간단히 구현할 수 있다. //UITapGestureRecognizer
            .when(.recognized) //제스처가 인식될 때마다
            .subscribe(onNext: { _ in
                print("view tapped") //출력
            })
            .disposed(by: disposeBag)
            //제스처 인식을 제거하려면 Disposable 객체를 dispose() 하면 된다.
        
        
        
        
        
        view.rx
            .anyGesture(.tap(), .longPress()) //한 번에 여러 제스처를 구현할 수도 있다.
            .when(.recognized) //when으로 recognizer state를 필터링 할 수 있다.
            .subscribe(onNext: { gesture in
                if let _ = gesture as? UITapGestureRecognizer {
                    print("view was tapped")
                } else {
                    print("view was long pressed")
                }
            })
            .disposed(by: disposeBag)
        
        
        
        
        
        view.rx
            .screenEdgePanGesture(edges: [.top, .bottom]) //가장자리 스와이프 방향
            .when(.recognized) //when으로 recognizer state를 필터링 할 수 있다.
            .subscribe(onNext: { _ in
                //gesture was recognized
            })
            .disposed(by: disposeBag)
            //제스처 인식을 제거하려면 Disposable 객체를 dispose() 하면 된다.
        
        //iPad Pro에서 스타일러스 만으로 스와이프 감지
//        let observable = view.rx.swipeGesture(.left, configuration: { recognizer in
//            recognizer.allowedTouchTypes = [NSNumber(value:UITouchType.stylus.rawValue)]
//        })
        
        
        
        
        
        view.rx
            .tapGesture()
            .when(.recognized)
            .asLocation(in: .window) //RxGesture는 asLocation(in: )으로 해당 위치를 가져올 수 있다.
            .subscribe(onNext: { location in
                print("Location : \(location)")
            })
            .disposed(by: disposeBag)
        
        
        
        
        
        view.rx
            .panGesture() //팬 제스처
            .asTranslation(in: .superview) //이벤트 변환. translation, velocity 반환
            .subscribe(onNext: { translation, velocity in
                print("Translation=\(translation), velocity=\(velocity)")
            })
            .disposed(by: disposeBag)
        
        
        
        
        
        view.rx
            .rotationGesture() //회전 제스처
            .asRotation() //이벤트 변환. rotation, velocity 반환
            .subscribe(onNext: { rotation, velocity in
                print("Rotation=\(rotation), velocity=\(velocity)")
            })
            .disposed(by: disposeBag)
        
        
        
        
        
        view.rx
            .transformGestures() //pan, pinch, rotate 제스처를 조합할 수 있다.
            //transformGestures()는 pan, pinch, rotate의 세 가지 제스처
            //세 가지가 모두 필요하지 않은 경우에는 비활성화 시킬 수 있다.
//            view.rx.transformGestures(configuration: { recognizers in
//                recognizers.pinchGesture.enabled = false
//            })
            .asTransform() //이벤트 변환. trnasform, velocity 반환
            .subscribe(onNext: { (transform, velocity) in
                self.view.transform = transform
            })
            .disposed(by: disposeBag)
        
        
        
        
        
        let panGesture = view.rx
            .panGesture()
            .share(replay: 1, scope: .whileConnected)
        
        panGesture
            .when(.changed)
            .asTranslation()
            .subscribe(onNext: { translation, _ in
                self.view.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
            })
            .disposed(by: disposeBag)
        
        panGesture
            .when(.ended)
            .subscribe(onNext: { _ in
                print("Done panning")
            })
            .disposed(by: disposeBag)
        
        //여러 장소에 동일한 제스처 Observable을 사용해야 할 수도 있다.
        //구독 하면, 제스처를 인식하고 연결되기 때문에 다른 곳에서 사용할 때
        //반복할 필요 없이 share(replay: scope:)를 활용할 수 있다.
    }
}

//Gesture는 개별 혹은 연속된 이벤트의 스트림으로 볼 수 있다.
//제스처는 대상 동작 패턴을 사용해 일부 객체를 대상으로 설정하고, 업데이트를 수신하는 함수를 만든는 작업이다.
//target-action pattern //클로저를 통해, 제스처를 조정할 수 있다.

//RxGesture는 모든 gesture recognizers를 사용할 수 있다. custom gesture를 구현할 수도 있다.
//rx.tapGesture(), rx.swipeGesture(_:), rx.longPressGesture(),
//rx.screenEdgePanGesture(edges:), rx.pinchGesture(), rx.panGesture(), rx.rotationGesture()

//https://github.com/RxSwiftCommunity/RxGesture

