//
//  PHPhotoLibrary+rx.swift
//  Combinestagram
//
//  Created by 근성가이 on 2018. 3. 30..
//  Copyright © 2018년 Underplot ltd. All rights reserved.
//

import Foundation
import Photos
import RxSwift

extension PHPhotoLibrary {
    static var authorized: Observable<Bool> { //액서스 권한을 부여 했는 지 여부. 간단히 Bool로 표현할 수 있다. p.132
        return Observable.create { observer in
            DispatchQueue.main.async { //비동기 메인 스레드
                if authorizationStatus() == .authorized { //authorizationStatus() : 앱 승인 정보를 받아온다.
                    observer.onNext(true)
                    observer.onCompleted()
                    //이미 승인 했다면, true 이벤트를 emit 후 onCompleted 한다.
                } else { //승인하지 않았다면
                    observer.onNext(false) //false 이벤트를 emit 후
                    requestAuthorization { newStatus in //다시 승인 요청을 한다.
                        observer.onNext(newStatus == .authorized) //승인을 여부를 emit하고
                        observer.onCompleted() //onCompleted emit
                    }
                }
                
                //처음 앱을 열었을 때는 false가 나온다. 그리고, 승인하면 false - true - .completed 순으로 진행된다.
                //이후에는 바로 true - .completed 된다.
                
                //처음 앱을 열고, 승인을 거부한 경우에는, false - false - .completed 순으로 진행된다.
                //이후 앱을 열고 승인을 다시 거부한 경에도 똑같이 false - false - .completed가 된다.
                //이 경우에는 시퀀스의 첫 째 요소는 항상 무시할 수 있고, 마지막 요소가 false인지만 확인하면 된다.
            }
            
            return Disposables.create()
        }
    }
}

//앱이 PHPhotoLibrary에 처음 엑서스 하면 OS가 비동기적으로 허가를 요청한다.
//처음에 엑서스 허가를 받고, 다시 로드하지 않는다면 앨범이 따로 보이지 않게 된다.
