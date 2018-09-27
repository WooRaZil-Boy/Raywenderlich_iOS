//Push는 인터넷으로 데이터를 보내 발생한다. 이 데이터는 Payload라고 하며, 푸시 알림 도착시 수행할 작업을 앱에 알리는 데 필요한 정보를 포함하고 있다.
//클라우드 서비스는 해당 Payload를 구성하고 하나 이상의 고유한 device token과 함께 APNs에 전송한다.
//초기에는 알림의 패킷 각 비트가 특정 의미를 갖는 packed-binary를 사용했다. 하지만, 이는 이해하거나 처리하기 어렵기 때문에 Apple에서는 Payload 구조를 변경해 JSON 구조를 사용한다.
//Apple에서 정의한 몇 가지 키가 있으며, 몇 가지 값은 필수이다. 일반 원격 알림의 경우 최대 Payload 크기는 4KB(4096Byte)이다.
//이를 넘어서는 경우, APNs에서 오류가 발생하며 알림이 통지되지 않는다. Payload를 수정해 이미지 등 크기가 큰 알림을 전송할 수도 있다.




//The aps dictionary key
//aps dictionary key는 Payload의 주요 허브로 다음과 같은 항목을 구성한다.
// • 최종 사용자에게 표시할 메시지
// • 앱 배지 번호를 성정해야 하는 항목
// • 알림이 도착하면 어떤 sound를 발생 시켜야 하는지
// • 사용자의 상호작용 없이 알림이 발생하는지 여부
// • 알림이 사용자 지정 작업 또는 사용자 인터페이스를 트리거하는 지 여부

//Alert
//가장 자주 사용하는 키이다. 이 키를 사용해 사용자에게 표시할 메시지를 지정해 줄 수 있다. 값을 문자열로도 설정할 수 있지만, dictionary로 사용하는 것이 좋다.
//가장 간단한 형태는 title과 body를 사용하는 것이다. p.26

//{
//    "aps": {
//        "alert": {
//            "title": "Your food is done.",
//            "body": "Be careful, it's really hot!"
//        }
//    }
//}

//dictionary를 사용하면 메시지의 title과 body를 모두 사용할 수 있다. title이 필요없는 경우 단순히 해당 key-value 쌍을 제거하면 된다.
//localization으로 일부 문제가 발생할 수도 있다.

//Localization
//dictionary에 localization 정보를 추가해 줄 수 있다. 방법은 두 가지가 있다.
// 1. 등록 시에 Locale.preferredLanguages를 호출하고, 사용자가 사용하는 언어 목록을 서버로 보낸다.
// 2. 모든 알림의 현지화된 버전을 앱 번들에 저장한다.
//서버에 모든 것을 보관하고, 각 사용자에게 번역된 메시지를 보내면 새 알림 메시지를 추가할 때 앱의 새 버전을 push할 필요 없다.
//local에서 처리하는 경우에는 title과 body 대신 title-loc-key 및 title-loc-args를 사용한다. 그리고 loc-key 및 loc-args를 사용할 수 있다. p.27

//{
//    "aps": {
//        "alert": {
//            "title-loc-key": "FOOD_ORDERED",
//            "loc-key": "FOOD_PICKUP_TIME",
//            "loc-args": ["2018-05-02T19:32:41Z"]
//        }
//    }
//}

//이때 iOS가 알림을 받으면 Localizable.strings를 보고 적절하게 번역한다.

//Grouping notifications
//iOS 12 부터 thread_identifier 키를 Alert의 dictionary에 추가하면, iOS가 동일한 식별자 값을 가진 모든 알림을 그룹화 한다(한 앱에서 여러 메시지 그룹화 p.28).
//UUID나 고유한 값을 사용해야 한다. “grouping” notification은 “collapsing” notification과 다르다. 알림 센터에서 그룹화된 알림을 확인할 수 있다.
//사용자가 원하는 경우, iOS 앱 설정에서 알림 그룹을 중지할 수 있다.

//Badge
//앱 아이콘에 숫자 배지를 표시한다. badge 키를 사용하여 번호를 지정해 주면 된다. 배지를 지우려면 0으로 설정해 주면 된다. p.29

//{
//    "aps": {
//        "alert": {
//            "title": "Your food is done.",
//            "body": "Be careful, it's really hot!"
//        },
//        "badge": 12
//    }
//}

//Sound
//알림이 도착했을 때 소리를 재생할 수 있다. 가장 일반적인 값은 iOS 표준 경고음이다(default). sound는 30초 이하여야 한다. 이보다 길면 default sound가 재생된다.
//Mac의 afconvert로 허용되는 4 가지 형식 중 하나로 변환 할 수 있다(Linear PCM, MA4(IMA/ADPCM), 𝝁Law, aLaw). p.30
//ex. $ afconvert -f caff -d LEI16 filename.mp3 filename.caf

//{
//    "aps": {
//        "alert": {
//            "title": "Your food is done.",
//            "body": "Be careful, it's really hot!"
//        },
//        "badge": 12,
//        "sound": "filename.caf"
//    }
//}

//Critical alert sounds
//중요한 alert을 표시해야 하는 경우에는 문자열이 아닌 key-value dictionary를 사용해야 한다. p.30

//{
//    "aps": {
//        "alert": {
//            "title": "Your food is done.",
//            "body": "Be careful, it's really hot!"
//        },
//        "badge": 12,
//        "sound": {
//            "critial": 1,
//            "name": "filename.caf",
//            "volume": 0.75
//        }
//    }
//}

// • critical : 이 값이 1이면, sound는 critical alert임을 나타낸다.
// • name : 사운드 파일
// • volume : 0.0 ~ 1.0




//Your custom data
//aps 키 외의 모든 것은 custom data로 사용된다. 푸시 알림과 함께 추가 데이터를 앱에 전달해야 하는 경우에 이를 사용할 수 있다.
//ex. geocaching 앱의 경우, 좌표 세트를 전달할 수 있다. p.31

//{
//    "aps": {
//        "alert": {
//            "title": "Save The Princess!"
//        }
//    },
//    "coords": {
//        "latitude": 37.33182,
//        "longitude": -122.03118
//    }
//}




//Collapsing notifications
//Payload는 서버가 APNs로 보내는 몇 가지 중 하나일 뿐이다. device token 외에도 추가 HTTP header로 알림을 처리하는 방법과 전달 방법을 지정해 줄 수 있다.
//apns-collapse-id HTTP 이 이런 헤더 중 하나이다. Apple은 새로운 알림이 오래된 알림을 대체할 때 여러 알림을 하나씩 축소할 수 있는 기능을 추가했다.
//고유한 식별자를 헤더 필드에 최대 64바이트까지 넣을 수 있다. 알림이 전송되고 이 값이 설정되면, iOS 는 이전에 전달된 동일한 값의 알림을 모두 삭제한다.
//apns-collapse-id 를 헤더에 추가하고 request하면, 같은 key를 가진 알림은 합쳐져서 전송된다. 추가 알림을 보내는 것 보다 "무시", "업데이트"가 필요한 경우 사용한다.
//third-party delivery service를 사용하는 경우에는 apns-collapse-id를 식별할 수 있는 특정 위치를 함께 제공해야 한다.
