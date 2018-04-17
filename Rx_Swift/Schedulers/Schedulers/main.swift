/*
 * Copyright (c) 2014-2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import RxSwift

print("\n\n\n===== Schedulers =====\n")

let globalScheduler = ConcurrentDispatchQueueScheduler(queue: DispatchQueue.global())
//background queue 사용하는 스케줄러 //이 스케줄러에서 실행되는 작업은 background queue에서 진행된다.
//ConcurrentDispatchQueueScheduler는 특정 큐의 스케줄러. 백그라운드 작업을 만들 때 유용하게 사용할 수 있다.
let bag = DisposeBag()
let animal = BehaviorSubject(value: "[dog]")

//Default
//animal
//  .dump()
//  .dumpingSubscription()
//  .disposed(by: bag)

//animal
//    .dump()
//    .observeOn(globalScheduler)
//    .dumpingSubscription()
//    .disposed(by:bag)

animal
    .subscribeOn(MainScheduler.instance) //subscribe는 메인
    .dump()
    .observeOn(globalScheduler) //observation은 글로벌
    .dumpingSubscription()
    .disposed(by:bag)
    //하지만, 밑의 animalsThread와 연관되어서 fruit처럼 제대로 실행되지 않는다.
    //이는 Rx가 기본적으로 비동기 또는 멀티 스레드로 생각할 때 자주 착각하는 부분이다.
    //Rx와 일반적인 추상화는 free-threaded로, 데이터 처리 시에 따로 지정되지 않은 경우엔
    //연산은 항상 original thread에서 실행된다.
    //thread 전환은 명시적으로 subscribeOn, observeOn 연산자를 사용한 후에 발생한다.

    //위의 코드는 잘못 쓴 경우이다. 연산이 특정 스레드에서 일어나고 있고, 그 이벤트들이 Thread()에서 푸시된다.
    //Subject의 속성으로 인해 Rx는 원본 스케줄러를 전화하고 다른 스레드로 이동할 수 없다.
    //Subjectr가 푸시된 곳을 직접 제어할 수 없기 때문이다.
    //이를 Hot and Cold Observable 문제라 한다.
    //Observable.create를 사용하면 Rx를 Thread 블록 내부에서 제어 할 수 있어서
    //스레드 처리를 보다 세밀하게 정의할 수 있다.

    //위의 코드는 hot observable. observable은 구독중에 side-effect가 없지만 이벤트가 생성되고
    //RxSwift가 그것을 제어할수 없는 자체 컨텍스트를 가지고 있다.(즉, 자체 스레드를 사용한다.)
    //cold observable은 observers가 subscribe하기 전에 어떤 요소도 생산하지 않는다.
    //이는 구독할때 일부 컨텍스트를 만들고 요소를 만들기 시작할때까지 자체 컨텍스트가 없는 것을 의미한다. p.313

    //???

let fruit = Observable<String>.create { observer in
    observer.onNext("[apple]")
    sleep(2) //2초 대기
    observer.onNext("[pineapple]")
    sleep(2)
    observer.onNext("[strawberry]")
    
    return Disposables.create()
}

//일반적인 사용. 메인 스레드에서 생성된다.
//fruit
//    .dump()
//    .dumpingSubscription()
//    .disposed(by: bag)

//백 그라운드 스레드에서 생성
//fruit
//    .subscribeOn(globalScheduler)
//    //background thread로 옮기려면, subscribeOn 사용
//    //subscribeOn로 구독하는 thread를 지정해 줄 수 있다. 아무것도 지정하지 않으면 기본값으로 현재 thread 사용 p.308
//    //subscribeOn으로 Observable 코드가 실행되는 스케줄러를 변경할수 있다
//    //(subscription operators 이 아니라 observable이 실제 event를 방출하는 코드)
//    //observable과 subscribed Observer이 같은 스레드에서 데이터를 처리 한다. p.309
//    .dump()
//    .dumpingSubscription()
//    .disposed(by: bag)

//백 그라운드 스레드에서 생성 후, 메인 스레드로 변경
fruit
    .subscribeOn(globalScheduler) //background thread
    .dump()
    .observeOn(MainScheduler.instance) //main thread
    //Observer의 작업 위치를 변경하려면 observeOn을 사용한다.
    //observeOn은 관찰이 일어나는 스케줄러를 변경한다(subscribeOn의 반대). p.310
    //dump는 백그라운드 스레드에서, dumpingSubscription는 메인 스레드에서 진행된다.

    //main observable은 background thread에서 이벤트를 처리하고
    //subscribing observer는 main thread에서 작업을 수행한다.

    //백그라운드 프로세스로 서버에서 데이터를 검색하고, 수신된 데이터를 처리해
    //MainScheduler로 전환해 최종 이벤트를 처리한 후 UI에 데이터를 표시하는 패턴으로 매우 자주 사용된다.
    .dumpingSubscription()
    .disposed(by:bag)

//Pitfalls
let animalsThread = Thread() { //자신의 스레드를 생성할 수 있다.
    sleep(3)
    animal.onNext("[cat]")
    sleep(3)
    animal.onNext("[tiger]")
    sleep(3)
    animal.onNext("[fox]")
    sleep(3)
    animal.onNext("[leopard]")
}

animalsThread.name = "Animals Thread" //스레드 이름 지정
animalsThread.start() //해당 스레드 실행

RunLoop.main.run(until: Date(timeIntervalSinceNow: 13))
//메인 스레드에서 모든 작업이 완료되면 터미널은 종료된다.
//하지만 이 코드에서 13초 동안 유지되도록 해, 글로벌 스케줄러의 작업을 확인할 수 있게 한다.







//Custom Scheduler를 만들 수 있지만, 거의 모든 경우 내장 스케줄러로 해결할 수 있다.

//Scheduler는 프로세스가 진행되는 상황을 나타낸다. thread, dispatch queue, entities, NSOperation등이 될 수 있다.
//Observable은 서버에 요청하고 일부 데이터 검색하고, 데이터를 어딘가에 저장하는 cache(사용자 정의 연산자)에 의해 처리된다.
//그 후, 데이터는 다른 스케줄러의 모든 구독자에게 전달된다. MainScheduler는 메인 스레드에 있어 UI 업데이트를 할 수 있다. p.305

//스케줄러는 GCD와 비슷하게 작동하므로 스레드와 혼동하는 경우가 많다.
//하지만, 동일한 스레드 또는 여러 스레드 위에 단일 스케줄러를 사용할 수도 있다(Custom Scheduler 사용 - 권장되지 않음). p.305
//스케줄러는 스레드가 아니며, 스레드와 항상 일대일 관계를 유지하지 않는다.

//Rx에서 가장 중요한 사항 중 하나는 내부 프로세스에서 생성중인 이벤트를 제외하고 제한없이 손쉽게 스케줄러를 전환하는 기능이다.
//Rx의 세 가지 기본 개념 : Observable, Subscribe, Operators

//올바른 스케줄러를 사용하고 있는지 항상 염두에 둬야 한다.
//• Serial scheduler : Rx는 연속적인 계산을 수행한다.
//  serial dispatch queue의 경우 scheduler는 자체 최적화를 수행할 수 있다.
//• Concurrent scheduler : Rx는 코드를 동시에 실행하려 시도하지만
//  observeOn과 subscribeOn은 작업을 실행해야 하는 순서를 보존하고, 구독이 올바른 스케줄러에서 종료되도록 한다.

//MainScheduler는 메인 스레드 맨 위에 위치한다. UI 변경 사항을 처리하고, 우선 순위 높은 작업 수행에 사용된다.
//서버 요청이나 부하가 많이 걸리는 작업은 메인 스레드에서 실행하지 않는 것이 좋다.
//UI 업데이트를 해야 하는 경우에는 MainScheduler로 전환해서 처리해야 한다.
//Driver를 사용할 때도 이용된다. Driver는 MainScheduler에서 항상 작업이 진행 되도록해
//응용 프로그램의 사용자 인터페이스에 직접 데이터를 바인딩 할 수 있는 기능을 제공한다.

//SerialDispatchQueueScheduler : Serial DispatchQueue를 추상화 한다. observeOn 사용에 큰 장점을 가진다.
//이 스케줄러로 직렬화 방식으로 백 그라운드 작업을 처리할 수 있다.
//ex. Firebase, GraphQL처럼 서버와 통신하는 응용 프로그램을 사용하는 경우, 많은 request를 동시에 보내는 게 아닌
//  큐에 넣고 하나씩 보내면 받을 때 한 번에 받아 부담이 될 수 있다.??

//ConcurrentDispatchQueueScheduler : SerialDispatchQueueScheduler와 유사하게
//DispatchQueue에서 추상 작업을 관리한다. 차이점은 스케줄러가 동시에 큐를 사용한다는 점이다.
//SerialDispatchQueueScheduler와 달리 observeOn 사용 시 최적화 되지 않으므로 어떤 스케줄러 사용 할 것인지
//고려해야 한다. ConcurrentDispatchQueueScheduler는 동시에 끝내야 하는 여러 task 처리에 좋은 옵션이다.
//ex. 용량 많은 다수 이미지를 한 번에 보여줘야 할 때.

//OperationQueueScheduler : ConcurrentDispatchQueueScheduler와 유사하지만,
//DispatchQueue를 통해 작업을 추상화하는 대신 NSOperationQueue를 통해 작업을 수행한다.
//실행중인 concurrent 작업이 더 많은 제어가 필요하지만 concurrent DispatchQueue로는 수행할 수 없는 경우에,
//OperationQueueScheduler를 사용해 concurrent 작업의 최대수를 조정할 수 있다.

//TestScheduler : 테스트에만 사용되므로, 일반 작업 시에는 사용하지 않는다.
//RxTest의 일부로 operator testing을 간소화한다.


