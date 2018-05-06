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

final class DataWriterMain: DataWriterType {
  func write(sym: String, value: Double) {
    DispatchQueue.main.async { //비동기 작업.
      //트랜잭션을 즉시 시작하는 대신 비동기로 작업을 예약해 객체를 동기화된 방식으로 유지한다.
      //이렇게 처리하는 것(GCD) 만으로도, Realm이 최적화를 진행하므로 속도가 훨씬 빠르고, 저장된 파일의 크기는 작아진다.
      
      //성능은 당연히 디바이스의 상태에 따라 달라진다. 또한, 동일한 수의 객체를 포함하는 파일이라도 크기가 다를 수 있다.
      //파일 크기는 데이터가 디스크에 기록된 조건에 따라 달라진다.
      //Realm은 자동으로 데이터를 압축하고, 파일 크기를 최소화하지만 여건에 따라 달라질 수 있다.
      
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
}


//많은 양의 데이터를 작성할 필요가 없는 경우, write 트랜잭션이 일반적으로 매우 빠르기 때문에
//모든 스레드(메인 스레드 포함)에서 Realm 파일에 안전하게 쓸 수 있다.


