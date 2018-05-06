/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import RealmSwift

final class DataWriterGCD: DataWriterType {
  private let writeQueue = DispatchQueue(label: "background", qos: .background, attributes: [.concurrent])
  //작업을 에약할 때마다, 반복되는 GCD를 추가해줄 필요 없도록 전용 큐를 추가해 준다.
  //기본 큐 보다 우선 순위가 낮은 백 그라운드 큐

  func write(sym: String, value: Double) {
    writeQueue.async {
      let realm = RealmProvider.sensors.realm //앱에 대한 Realm 참조
      //provider 구조체를 사용해 추상화 시켜 코드를 간결하게 유지할 수 있다.
      
      guard let sensor = realm.object(ofType: Sensor.self, forPrimaryKey: sym) else { return }
      //sensor 객체 가져오기
      
      try! realm.write { //수신된 센서 판독 값을 앱의 Realm 파일에 저장
        sensor.addReadings([Reading(value)])
        //addReadings 메서드는 판독한 값을 추가하는 래핑 메서드
      }
    }
  }
  //DataWriterMain.swift에서 메인 큐를 사용한 것 보다 속도가 느리고, 파일 크기가 매우 커진다.
}

//DataWriterMain.swift에선 메인 큐를 사용해서 성능을 향상 시켰다.
//하지만 메인 스레드는 serial queue이며, 많은 양의 작업을 할 때에만 눈에 띄는 성능 향상을 기대할 수 있다.
//또 다른 문제점은 UI관련 작업이 많아 메인 스레드에 과부하가 걸리면, 앱의 전체 성능이 저하되고 응답이 느려질 수 있다.

//Realm이 해당 객체를 스레드 별로 생성된 DB 스냅 샷으로 제한한다.
//따라서 메인 GCD 큐에서 작업하는 것은 메인 스레드에서 작업하는 것이다.
//비동기 작업으로 작업하든 그렇지 않든 관계없이 항상 Realm 파일의 동일한 스냅 샷으로 작업한다.

//GCD는 디스패치 큐라는 스레드를 추상화한다. 디스패치 큐는 동시 작업을 수행하기 위해 스레드 풀을 사용한다.
//풀의 크기 또는 스레드의 재사용 빈도는 구현에 따라 달라진다.
//디버그 콘솔에서 일시정지를 선택해 실행을 일시 중지 시켜서 확인해 보면, 큐가 여러 스레드를 생성하는 것을 볼 수 있다. p.205
//여기의 구현으로 대량의 데이터를 디스크에 쓰려고 하면, 수 많은 서로 다른 스레드가 지속적으로
//작은 write 트랜잭션을 자신의 Realm 스냅 샷에 commit하면서, 다른 모든 스레드가 자체 스냅 샷을 새로 고침한다.
//따라서, 성능이 저하 되고, Realm 파일의 크기가 커지게 된다.
