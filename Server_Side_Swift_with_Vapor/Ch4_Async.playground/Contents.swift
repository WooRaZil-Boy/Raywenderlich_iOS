//Async
//Vapor 3의 가장 중요한 새 기능 중 하나는 비동기이다. 동기식으로 처리할 때, 메인 스레드 하나만 사용한다면, 해당 서버 작업이 끝날 때까지 스레드가 차단된다.
//반명 비동기식 서버에서는 하나의 스레드에서 여러 작업을 따로 처리할 수 있다. p.35
//서버가 여러 개의 스레드를 가질 수 있지만, 그 수에는 한계가 있다. 스레드 간의 컨텍스트 전환은 비용이 많이 들며, 모든 데이터 액세스가 스레드로부터 안전하도록 보장하는 것
//또한 소모적인 작업이면서 오류가 발생하기 쉽다. 결과적으로 스레드를 추가하여 동기식으로 구현하는 것은 비효율적인 방법이다.




//Futures and promises
//Vapor에서는 일반적인 동기적 상황을 Promise라 한다.
//func getAllUsers() -> [User] {
//    // do some database queries
//}
//이 경우에는, 동기적으로 진행되므로, 함수의 반환형인 [User]가 확정적이다.

//하지만 비동기적 상황에서는 함수가 완료됐을 때, 반환해야할 값이 아직 없을 수도 있다(DB 작업 등). Vapor에서는 이런 경우 Future라는 유형을 쓴다.
//func getAllUsers() -> Future<[User]> {
//    // do some database queries
//}
//미래에 [User]타입으로 반환할 수 있지만, 지금은 할 수 없을 수 있는 경우 사용한다.




//Working with futures
//Vapor에서는 Future가 매우 광범위하게 사용된다.

//Unwrapping futures
//Vapor는 Future을 직접 다루지 않고도 Future로 작업할 수 있는 여러 convenience function을 제공한다.
//Future을 사용하고, Promise가 실행될 때까지 기다릴 필요가 있는 경우가 많이 있다.
//이 작업에는 두 가지 주요 함수가 사용된다.
//• flatMap(to:) : Promise 클로저가 Future를 반환할 때 사용한다.
//• map(to:) : Promise 클로저가 Future이 아닌 다른 유형을 반환할 때 사용한다.

//return database
//    .getAllUsers()
//    //DB에서 모든 User를 가져온다. getAllUsers는 Future<[User]>를 반환한다.
//    .flatMap(to: HTTPStatus.self) { users in
//        //flatMap(to:)클로저는 [User](Promise)를 매개변수로 받아 Future<HTTPStatus>를 반환한다.
//        //반환한 Future<[User]> 타입을 flatMap(to:)를 사용해 결과를 unwrap한다.
//
//        let user = users[0]
//        user.name = "Bob"
//        //업데이트
//
//        return user.save().map(to: HTTPStatus.self) { user in
//            //user.save()로 갱신된 사용자 DB에 저장
//            //Future<User>를 반환하지만, HTTPStatus이 Future가 아니므로 map을 사용한다.
//            return HTTPStatus.noContent
//            //적절한 HTTPStatus값을 반환한다.
//        }
//}
//
//Transform
//때로는 Future 결과 값을 신경 쓰지 않고 완료 여부만 중요한 경우가 있다.
//이런 경우에는 transform(to:)을 사용해 단순화할 수 있다.
//return database
//    .getAllUsers()
//    .flatMap(to: HTTPStatus.self) { users in
//        let user = users[0]
//        user.name = "Bob"
//
//        return user.save().transform(to: HTTPStatus.noContent)
//        //위의 코드와 같지만, 이부분만 다르다. 코드가 간결해지고 유지하기 쉬워진다.
//}

//Flatten
//다수의 Future 결과를 기다려야 하는 경우에 flatten(on:)을 사용한다.
//static func save(_ users: [User], request: Request) -> [Future<HTTPStatus>] {
//    let userSaveResults: [Future<User>] = []
//    //user.save()의 반환형인 Future<User>의 배열 정의
//
//    for user in users {
//        //루프를 돌면서 값을 배열에 추가
//        userSaveResults.append(user.save())
//    }
//
//    return userSaveResults.flatten(on: request)
//        //모든 Future가 완료될 때까지 대기하려면 flatten(on:)을 사용한다.
//        //주로, 작업을 수행하는 Worker 스레드, 보통 Vapor의 Request를 사용한다.
//        .transform(to: HTTPStatus.created)
//    //201 Created 상태 반환
//}

//Creating futures
//때로는 사용자의 필요에 따라 Future를 만들어야 할 때가 있다. if 문이 non-Future를 반환하고, else 블록이 Future를 반환한다면,
//컴파일러는 동일한 유형이 아니라는 경고를 할 것이다. 이런 경우, Future.map(on :)을 사용하 non-Future를 Future로 변환해야 한다.
//func createTrackingSession(for request: Request) -> Future<TrackingSession> {
//    //request를 받아 TrackingSession을 생성하는 함수. Future<TrackingSession>를 반환
//    return request.makeNewSession()
//}

//func getTrackingSession(for request: Request) -> Future<TrackingSession> {
//    //request를 받아 TrackingSession을 가져오는 함수
//    let session: TrackingSession? = TrackingSession(id: request.getKey())
//    //request의 key를 사용해, TrackingSession을 만든다. nil이 반환될 수 있으므로 optional
//
//    guard let createdSession = session else {
//        //세션이 성공적으로 만들어진 경우에만 진행
//        return createTrackingSession(for: request)
//        //제대로 세션이 만들어지지 않은 경우, 새로운 TrackingSession을 생성한다.
//    }
//
//    return Future.map(on: request) { createdSession }
//    //Future.map(on:)을 사용해 Future유형을 반환할 수 있다.
//}
//createTrackingSession(for :)이 Future <TrackingSession>을 반환하기 때문에
//future.map(on :)을 사용하여 createdSession을 Future<TrackingSession>으로 설정해야 한다.

//Dealing with errors
//Vapor는 오류 처리를 자주 사용한다. 대부분의 함수의 경우 오류처리를 지원해 커스터마이징할 수 있다.
//비동기에서의 오류 처리는 Promise가 언제 실행될 지 모르기 때문에 일반 Swift의 do-try-catch를 사용할 수 없다.
//기본적으로 Vapor는 Future와 함께 작동하는 자체 do-try-catch 콜백을 가지고 있다.
//let futureResult = user.save()
//futureResult.do { user in
//    //save가 성공하면, 해당 do 블록이 실행되고, unwrapping된 값이 첫 번째 매개 변수로 사용된다.
//    print("User was saved")
//    }.catch { error in
//        //Future가 실패하면 catch 블록을 실행해 오류를 전달한다.
//        print("There was an error saving the user: \(error)")
//}
//이 do-try-catch 메서드는 오류가 나더라도 중단되지는 않지만 해당 오류를 확인할 수 있다.
//save() 호출이 실패하고 futureResult를 반환하 오류는 계속해서 체인에 전파되고 수정을 시도할 것이다.
//Vapor는 이러한 유형 오류를 처리하기 위해 catchMap(_:)과 catchFlatMap(_:)을 제공한다.
//이 메서드들은 오류를 처리하고 수정하거나 다른 오류를 발생 시킬 수 있다.
//return user.save(on: req).catchMap { error -> User in
//    //사용자 저장 함수. 오류 처리는 catchMap(_ :)에서 진행. 오류를 매개변수로 사용해서 해결된 Future 유형(여기선 User, Promise)을 반환해야 한다.
//    print("Error saving the user: \(error)")
//
//    return User(name: "Default User")
//    //오류 시 반환할 기본 User
//}
//Vapor는 클로저가 Future를 반환해야 할 때, catchFlatMap(_:)를 사용할 수 있다.
//return user.save().catchFlatMap { error -> Future<User> in
//    print("Error saving the user: \(error)")
//
//    return User(name: "Default User").save()
//}
//catchMap(_:)과 catchFlatMap(_:)은 실패시 클로저만 실행한다.

//Chaining futures
//Vapor에서는 Future 클로저를 중첩하지 않고 체이닝하여 처리할 수 있다.
//return database
//    .getAllUsers()
//    .flatMap(to: HTTPStatus.self) { users in
//        let user = users[0]
//        user.name = "Bob"
//
//        return user.save().map(to: HTTPStatus.self) { user in
//            return HTTPStatus.noContent
//        }
//}
//map(to:)과 flatMap(to:)을 써서 아래처럼 쓸 수 있다.
//return database
//    .getAllUsers()
//    .flatMap(to: User.self) { users in
//        let user = users[0]
//        user.name = "Bob"
//
//        return user.save()
//    }.map(to: HTTPStatus.self) { user in
//        return HTTPStatus.noContent
//}
//Chaining futures를 사용해, 코드 중첩을 줄일 수 있으며 관리하기 더 쉽다.
//특히 비동기적 환경에서 유용하다. 두 코드는 완전히 같은 코드이며 개인의 취향에 따라 선택하면 된다.

//Always
//때로는 Future의 결과에 상관없이 무언가를 실행해야 할 때가 있다.
//ex. connect 해제, 알림을 트리거, Future가 실행되었음을 기록
//always 콜백을 사용해 이를 해결할 수 있다.
//let userResult: Future<User> = user.save()
//userResult.always { //결과를 always에 연결
//    print("User save has been attempted")
//    //Future를 실행할 때 출력된다.
//}
//실패하든 성공하든 Future의 결과에 관계없이 항상 클로저가 실행된다.

//Waiting
//특정 상황에서는 실제 결과가 반환될 때까지 기다려야 하는 경우도 있다.
//메인 이벤트 루프에서는 wait()를 사용할 수 없다. 대부분의 경우 이에 속한다.
//하지만 비동기 테스트 작성이 어려운 테스트에서 유용하게 사용할 수 있다.
//let savedUser = try user.save(on: connection).wait()
//SaveUser는 wait()를 사용하기 때문 Future<User>이 아닌 User객체이다.
//Promise 결과가 실패하면 wait()는 오류를 발생 시킨다.




//SwiftNIO
//Vapor는 SwiftNIO(https://github.com/apple/swift-nio)라이브러리 위에서 만들어졌다.
//SwiftNIO는 Java의 Netty와 같은 교차 플랫폼, 비동기 네트워킹 라이브러리이다.
//SwiftNIO는 Vapor에 대한 모든 HTTP 통신을 처리해서 데이터의 연결과 전송을 관리한다.
//또한 작업을 수행하고 Promise를 이행하는 Future를 위한 모든 EventLoops를 관리한다.
//각 EventLoop에는 자체 스레드가 있다. Vapor는 SwiftNIO와 모든 상호 작용을 관리하고 사용할 수 있는 Swifty API를 제공한다.
//Vapor는 라우팅 요청과 같이 서버의 상위 수준을 담당한다.
