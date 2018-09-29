//
//  AppDelegate.swift
//  PushNotifications
//
//  Created by 근성가이 on 29/09/2018.
//  Copyright © 2018 근성가이. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder {
    
    var window: UIWindow?
}

//Adding capabilities
//푸시 알림을 사용하려면, Xcode에서 등록을 해야 한다. p.34
// 1. ⌘ + 1 (View ▸ Navigators ▸ Show Project Navigator) 에서 가장 위에 있는 프로젝트를 선택한다.
// 2. target을 선택한다.
// 3. Capabilities 탭을 선택한다.
// 4. Push Notifications을 ON으로 전환한다.




//Registering for notifications
//푸시 알림은 Opt-in 기능이므로 사용자의 권한이 있어야 한다. 사용자는 언제든 알림을 끌 수 있기 때문에 앱이 시작될 때마다 알림을 사용하는지 여부를 확인해야 한다.
//앱이 푸시 알림에 대한 액세스를 처음 요청할 때만, iOS는 사용자에게 알림을 수락하거나 거절하라는 alert을 표시한다.

extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
            //앱이 시작될 때 마다 사용자에게 badge, sound, alert을 사용자에게 보낼 수 있는 권한을 요청한다.
            //getNotificationSettings(completionHandler:) 로는 현재 앱에 어떤 권한이 허용되었는지 확인할 수 있다.
            guard granted else { return }
            
            //badge, sound, alert 중 하나라도 권한이 있는 경우
            
            DispatchQueue.main.async { //메인 스레드에서 실제 등록 메서드를 실행해야 한다.
                application.registerForRemoteNotifications() //APNs 로 원격 알림을 받기 위해 앱을 등록한다.
                //등록이 성공하면, 앱은 delegate의 application(_:didRegisterForRemoteNotificationsWithDeviceToken:) 를 호출하고
                //토큰을 전달한다. 이 토큰을 디바이스에 대한 원격 알림을 생성하는 서버로 전달해야 한다.
                //등록이 실패하면 application(_:didFailToRegisterForRemoteNotificationsWithError:) 를 호출한다.
            }
        }
        
        return true
    }
}

//Provisional authorization
//하지만 위와 같은 alert은 앱이 처음 시작될 때 사용자에게 불쾌함을 줄 수 있다. 실제로 알림을 거부하는 사람들의 비율도 꽤 높다.
//이 문제를 해결하기 위해 Apple은 requestAuthorization에 전달할 수 있는 UNAuthorizationOptions 열거형에 대한 또 다른 사용법을 제공한다.
//options 인수에 .provisional을 포함하면 권한을 request하지 않고 알림이 자동으로 사용자의 알림 센터에 전달된다.
//이는 임시 알림으로 이에 대한 alert이나 sound는 표시되지 않는다. 이 option의 장점은 알림 센터를 보고 사용자가 권한 여부를 결정할 수 있다는 것이다.
//그럴 경우, 그곳에서 승인하기만 하면, 이후 알림이 일반 푸시 알림으로 표시된다.

//Critical alerts
//앱 유형에 따라 권한을 요청해야할 다른 유형이 있다. 앱이 health, medical, home, security, public safety 등에 연관된 알림을 보내야 할 경우
//사용자가 알림 권한을 거부했더라도 .criticalAlert 열거형으로 알림을 요청할 수 있다.
//Critical alert은 사용자가 방해 금지 혹은 벨소리를 꺼 놓았더라도 사운드를 재생한다. 이 알림을 위해선 Apple Developer Portal에서 따로 자격을 얻어야 한다.
//https://apple.co/2JwRvbv




//Getting the device token
//앱이 알림에 대한 권한을 얻으면, iOS는 앱에 device token을 제공하는 다른 delegate 메서드를 호출한다. 토큰은 고유하며 APNs에서 app-device를 식별한다.
//iOS는 이를 String이 아닌 Data 유형으로 제공한다. 대부분의 push service provider는 String을 기대하기 때문에 이를 변환해야 한다.

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("") { $0 + String(format: "%02x", $1) } //토큰은 기본적으로 16진수 문자(character) 집합이다.
        //단순히 토큰을 16진수 문자열로 변환한다. 이 방법 외에도 다양한 방법으로 변환할 수 있다.
        //reduce는 클로저를 사용해 시퀀스의 요소를 단일 값으로 결합한다. 따라서 각 바이트를 가져와 16진수로 변환한 다음 누적한다.
        print(token)
    }
}

//여기서 주의할 점은 토큰의 길이를 추정하거나 제한해선 안 된다는 것이다. 효율성을 위해 토큰의 길이를 하드 코딩하는 경우가 있는데,
//이는 SQL 등에 코튼을 저장할 때 문제가 발생할 수 있다. 또한 장치 토큰 자체가 변경될 수 있다.
//예를 들어 동일 사용자가 다른 기기에 앱을 설치하고 백업해둔 데이터를 복원하거나 iOS를 재설치하는 경우 Apple에서는 새로운 device token을 발급한다.
//토큰을 특정 사용자에 연결해서는 안 된다. device에 연결해야 한다.

