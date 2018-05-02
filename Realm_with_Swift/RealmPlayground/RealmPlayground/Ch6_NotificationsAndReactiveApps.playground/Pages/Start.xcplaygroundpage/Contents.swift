/*:
 # Notifications and Reactive Apps
 # 🖥📱⌚️

 This section provides several asynchronous examples that work best
 when executed individually.

 Table of contents:

 - [Observing an Object](Observing%20an%20Object)
 - [Observing a Collection](Observing%20a%20Collection)
 - [Collection Changes](Collection%20Changes)
 - [Avoid notifications for given tokens](Avoid%20notifications%20for%20given%20tokens)
 - [Realm-wide notifcations](Realm-wide%20notifications)
 */

//Change notifications
//Realm은 앱에 사용된 메모리 객체와 디스크에 저장된 데이터를 매핑하여 데이터를 최신으로 유지한다.
//데이터가 변경된 시기를 알아내기 Notification API를 사용할 수 있다.
//모델을 지속하는 코드와 UI용 코드를 분리할 수 있다. p.114

//Realm에서 제공하는 Notification은 3가지 레벨이 있다.
//• Object level : 객체 수준. 속성 변경을 위해 단일 객체를 관찰
//• Collection level : 콜렉션 수준. 콜렉션 요소나 콜렉션 자체에서 발생하는 변경 사항에
//  대해(List, Results, linking objects property)을 관찰
//• Realm level : write 트랜잭션 후 알림이 전송되므로 전체 Realm에 대한 변경 관찰




//Notification details
//알림 사용 시 스레드와 Apple의 자체 실행 루프에 관해 주의해야 할 몇 가지 사항이 있다.
//1. Threads : 앱의 스레드 또는 다른 프로세스에서 데이터 변경 사항에 대한 알림을 받는다.
//  알림 처리기는 알림을 구독한 동일한 스레드에서 호출된다.
//2. Run loop : Realm은 Apple의 실행 루프를 사용하여 변경 알림을 제공한다.
//  따라서 실행 루프가 설치된 스레드에서만 알림을 구독할 수 있다.
//  기본적으로 메인 스레드에는 실행 루프가 있지만, 새 스레드를 생성하거나 GCD를 사용하여
//  만드는 모든 스레드에는 루프가 없다. 백그라운드 스레드에서 실행 루프를 설치하고
//  변경 사항을 구독하는 방법이 있다.
//3. Notifications granularity : Realm은 write 트랜잭션이 성공하면, 모든 관찰자에게
//  변경 알림을 보낸다. 이러한 구독 스레드의 실행 루프(다른 작업과 함께 사용되는 경우도 있다)를
//  사용해 전달되므로 알림이 전달되기 전에 Realm에서 다른 변경이 수행될 수 있다.
//  이 경우 Realm은 변경 사항을 집계하여 제공한다.
//4. Persisted objects only : Realm은 지속되는 객체에 대한 변경 사항만 관찰할 수 있다.
//  즉, 객체를 Realm에 추가해야 한다.
//5. Notification tokens : 알림을 구독하면, 토큰 객체가 반환된다. 토큰 객체에서
//  invalidate()를 호출하거나 토큰 객체가 메모리에서 해제될 때까지 알림은 특정 구독에 전달
//  된다. ex. 컨트롤러의 속성에 의해 유지되고, 컨트롤러가 해제되는 경우




//Editor ▸ Show Rendered Markup으로 마크 업 텍스트로 전환할 수 있다.
//모듈을 못 찾는 오류가 날 때, 플레이그라운드의 파일 관리자(오른쪽 패널)에서 플랫폼을
//macOS로 변경 후 다시 iOS로 변경하면 해결된다.
