//: Playground - noun: a place where people can play

//RxSwift는 새로운 데이터에 반응하여, 순차적으로 분리된 방식으로 코드를 처리해 비동기 프로그래밍을 간소화한다.

//비동기 프로그래밍
//• NotificationCenter : 장치 방향이 바뀌거나 키보드 등의 이벤트가 발생할 때 코드를 실행
//• The delegate pattern : 임의의 시간에 다른 클래스나 API에 의해 실행될 메서드 정의.
//• Grand Central Dispatch : 추상화. 대기열에서 순차적으로 실행되도록 코드를 예약하거나 우선 순위 다른 여러 큐에서 동시에 작업 실행
//• Closures : 클래스간에 전달할 수 있는 분리된 코드 조각을 만들어 각 클래스가 코드의 실행 여부, 횟수, 컨텍스트 결

//외부 요인에 따라 코드가 완전히 다른 순서로 실행될 수 있다.



//Synchronous code
var array = [1, 2, 3]

for number in array {
    print(number)
    array = [4, 5, 6] //array는 변경 되었지만, 루프에는 영향을 주지 않는다.
}

print(array)

//Synchronous code
array = [1, 2, 3]
var currentIndex = 0

func printNext(_ sender: Any) {
    //버튼을 탭하는 것에 대한 반응으로 이 메서드가 실행된다고 가정 //@IBAction
    print(array[currentIndex])
    
    if currentIndex != array.count-1 {
        currentIndex += 1
    } //버튼을 누를 때마다 다음 배열의 요소를 출력한다.
} //해당 메서드의 array의 요소는 메서드 코드 외부에서 추가되거나 삭제될 수 있다.

//비동기 코드 작성시의 문제 1. 코드가 실행되는 순서 2. 변경 가능한 데이터의 공유
//RxSwift로 이 문제들을 관리할 수 있다.



//일반적으로 RxSwift는 다음과 같은 목표를 지향한다.
//1. State, and specifically, shared mutable state : 비동기 코드를 구성하고 공유할 때, 앱의 상태를 관리한다.
//2. Imperative programming : 명령형 프로그래밍을 통해 앱이 언제 어떻게 작동해야 하는지 정확하게 알려준다.
//3. Side effects : 통제가능한 Side effects를 발생시킨다. 어떤 코드가 Side effects를 일으키고 데이터를 처리, 출력하는 지 결정한다.
//4. Declarative code : 선언적인 코드로 동작을 정의하고, 관련 이벤트가 있을 때마다 동작을 실행하고 작업할 수 있다.
//      (단순 for 루프와 동일한 가정을 한다. 변경 불가능한 데이터로 작업하고 순차적이고 결정적인 방법으로 코드를 실행한다.)
//5. Reactive systems
//      Responsive : 반응. 앱의 상태를 항상 최신으로 유지한다.
//      Resilient : 복원성. 각 동작은 격리되어 있고 오류 복구를 제공한다.
//      Elastic : 탄성. 코드는 다양한 작업을 처리하고 지연된 처리를 한다.
//      Message driven : 메시지 기반. 구성 요소는 메시지 기반으로 기능을 개선하고 구현과 분리



//RxSwift의 세가지 요소
//1. Observables : 일련의 이벤트를 비동기적으로 생성(클래스는 다른 클래스에서 나온 값을 옵저버할 수 있다). Observables는 3가지 이벤트가 있다.
//      A next event : 최신 혹은 다음 데이터 값을 전송.
//      A completed event : 이벤트가 성공하고, 시퀀스를 종료. 다른 이벤트를 발생시키지 않는다.
//      An error event : 오류로 종료. 다른 이벤트를 발생 시키지 않는다.
//  Observables의 시퀀스는 2개가 있다.
//      Finite observable sequences : 시퀀스가 몇 개의 값을 전송하면서 completed 되거나 errored가 된다.
//      Infinite observable sequences : 종료되지 않고 무한히 돌아간다. ex) UI 이벤트
//2. operators : 비동기에서 논리를 구현하기 위한 연산자.
//3. schedulers : Rx의 GCD. 커스텀으로 생성할 수 있지만, 미리 정의되어 있는 스케쥴러를 사용하는 경우가 많다.



//RxCocoa는 UIKit의 클래스를 포함하고 있다. 더 나은 클래스를 제공하고, UI 요소의 반응에 대한 처리를 쉽게 구현할 수 있다.
