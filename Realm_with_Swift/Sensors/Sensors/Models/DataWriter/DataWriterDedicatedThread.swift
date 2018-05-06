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

final class DataWriterDedicatedThread: NSObject, DataWriterType {
  private var writeRealm: Realm! //사용할 Realm 인스턴스
  //지금까지는 Realm 인스턴스에 대한 참조를 사용하지 않았다. 항상 configuration을 사용했다.
  //여기서는 항상 같은 전용 스레드를 사용해 write 할 것이므로 Realm 자체에 대한 참조를 유지하는 것이 안전하다.
  private var thread: Thread! //Realm에서 write에 사용할 작업 스레드
  
  private var sensors: Sensor.SensorMap! //[String: Sendor]의 typealias //캐싱
  
  private static let bufferMaxCount = 1000 //디스크에 유지하기 전에 메모리에 보관할 최대 reading 값의 수
  //1000개가 넘으면 이 객체를 Realm에 write한다. //batch
  private var buffer = [String: [Reading]]() //들어오는 reading 값을 저장해 놓은 배열을 담고 있는 Dictionary
  private var bufferCount = 0 //현재 버퍼링된 객체 수를 추적하는 정수 카운터
  
  override init() {
    super.init()
    
    thread = Thread(target: self, selector: #selector(threadWorker), object: nil)
    //threadWorker에서 스레드를 사용하기 전에 스레드를 초기화 한 후
    thread.start() //스레드를 실행해야 한다.
  }
  
  func write(sym: String, value: Double) {
    precondition(thread != nil, "Thread not initialized") //assert와 비슷.
    //초기화되지 않았다면 오류를 내고 종료
    
    perform(#selector(addReading), on: thread, with: [sym: value], waitUntilDone: false, modes: [RunLoopMode.defaultRunLoopMode.rawValue])
    //addReading을 실행한다. 주어진 스레드에서 with 파라미터로 실행
    //perform(_: on: with: waitUntilDone: modes:)의 제한 사항은
    //addReading(reading :)이 @objc로 정의되어 있어야 하고,
    //포함하는 클래스(ex. DataWriterDedicatedThread)가 NSObject이어야 한다.
    //또한 Objective-C 호환 유형으로 매개 변수를 제한하므로, sym, value를 튜플이나 구조체로 전달할 수 없다.
    //여기서는 단순히 Dictionary<String, Double> 이지만, 복잡한 데이터 구조에서는 사용자 정의 클래스가 필요할 수 있다.
  }
  //전용 스레드를 사용해서 구현하면, 메인 큐에서 비동기로 작업한 것 보다도 성능이 크게 향상된 것을 볼 수 있다.
  
  @objc private func threadWorker() {
    defer { //현재 코드 블록을 벗어날 때 defer 내의 코드를 실행한다. 지연 블록
      Thread.exit() //당장 실행하지 않고, threadWorker가 종료될 때 실행한다.
      //현재의 코드 블록이 종료된 후 코드가 실행되는 것이 보장된다. 예기치 못한 오류가 나더라도 Thread를 종료할 수 있다.
    }
    //defer는 스택에 쌓이게 된다. 따라서 여러 개의 defer 문이 있는 경우 역 순으로 실행된다.
    //https://soooprmx.com/archives/6118
    
    writeRealm = RealmProvider.sensors.realm
    sensors = Sensor.sensorMap(in: writeRealm) //모든 Sensor 객체를 저장 //캐싱
    
    while thread != nil, !thread.isCancelled { //스레드가 다른 프로세스에 의해 취소될 때까지 실행
      RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: Date.distantPast)
      //전용 스레드를 활성 상태로 유지하고, 일부 데이터를 앱의 Realm에 쓸 코드 준비.
      
      //RunLoop는 소스에 대한 입력과 Timer 이벤트를 처리한다. 스레드의 관리
      //http://wlaxhrl.tistory.com/63
    }
    
    writeBuffer(buffer) //버퍼의 Max인 1000에 도달하지 않았는데 클래스가 해제되면, 그 데이터들이 손실된다.
    //따라서 마지막으로 메모리 해제하기 전에 버퍼에 남아 있는 데이터의 수가 Max에 미달하더라고 write 한다.
    sensors = nil //스레드가 메모리에서 해제될 때, sensors를 비워준다.
  }
  
  @objc private func addReading(reading: [String: Double]) { //전용 스레드에서 실행되는 것이 보장된다.
    //센서의 reading 값을 디스크에 저장할 때 사용할 helper
    guard let sym = reading.keys.first, let value = reading[sym] else { return }
    
//    guard let sensor = writeRealm.object(ofType: Sensor.self, forPrimaryKey: sym) else { return }
//    //해당 센서 기록을 가져온다.
//
//    try! writeRealm.write { //추가
//      //RealmProvider의 프록시를 사용하지 않고 직접 Realm 파일을 쓴다. writeRealm에 이미 인스턴스를 가지고 있기 때문
//      //workerThread와 addReading(reading :)는 항상 전용 스레드에서 실행되므로 Realm 참조를 유지하는 것이 안전
//      sensor.addReadings([Reading(value)])
//    }
    
//    sensors[sym]?.addReadings([Reading(value)])
    //위에서 주석처리한 부분을 없애고, 대신 캐시된 객체를 사용한다.
    
    var bufferToProcess: [String: [Reading]] = [:] //새 버퍼를 사용해 reading 값을 보관
    
    if buffer[sym] == nil { //현재 센서의 배치에서 첫 번째 reading 값이라면,
      buffer[sym] = [] //센서의 reading 값을 보유할 배열을 만든다.
    }
    
    buffer[sym]!.append(Reading(value)) //버퍼에 reading을 추가하고
    bufferCount += 1 //버퍼 카운트를 올린다.
    
    if bufferCount > DataWriterDedicatedThread.bufferMaxCount {
      //버퍼 Max에 도달했는지 확인
      bufferToProcess = buffer //버퍼링된 값 복사
      bufferCount = 0 //버퍼 카운트 재 설정
      buffer = [:] //버퍼 재 설정
    }
    
    guard !bufferToProcess.isEmpty else { return } //버퍼링 된 reading 값이 있는 지 확인
    
    writeBuffer(bufferToProcess) //버퍼를 쓴다.
    //하나의 트랜잭션에서 여러 작업을 일괄처리(batch)하면, 성능을 크게 향상 시킬 수 있다.
  }
  
  func writeBuffer(_ batch: [String: [Reading]]) {
    try! writeRealm.write {
      batch.forEach { sym, values in //batch를 루프
        sensors[sym]?.addReadings(values) //각 센서 객체에 reading 목록을 추가
      }
    }
  }
  
  func invalidate() {
    //스레드를 취소하고, 객체의 상태를 지우는 메서드
    thread.cancel() //스레드를 취소해 라이프 사이클을 완전히 정리할 수 있다.
  }
}

//DataWriterGCD.swift에서 나타난 Realm 파일 크기가 커지는 문제는 Xcode 디버거가 실행 중일 때 나타난다.
//아이콘을 직접 탭하여 응용 프로그램을 실행하면, 파일 크기가 적당한 한도에서 안정적으로 유지된다.
//하지만, 동시에 많은 스레드를 사용하면서, 성능이 저하되는 문제는 해결되지 않는데, 이는
//GCD로 작업을 분산하는 대신 자체 스레드로 관리해서 해결할 수 있다.

//GCD는 비동기 작업을 실행할 때 사용할 수 있는 훌륭한 추상화 API이다.
//하지만, Realm에서 많은 write 트랜잭션이 진행될때 GCD의 내장된 최적화 기능이 오히려 성능을 저하시킨다.
//모든 DB의 write 트랜잭션을 수행할 전용 스레드를 수동으로 관리해 성능을 향상 시킬 수 있다.

//addReading(reading: )이 전용 스레드에서 실행되는 것이 보장되므로, 항상 필요한 일부 객체를 미리 가져와서
//데이터를 쓸 필요가 있을 때마다 반복적으로 가져오는 대신 writer 클래스에 저장할 수 있다.

//여기서, sensor의 reading 값을 Relam write 트랜잭션으로 쓸 때 가장 많은 병목 현상이 일어난다.
//모든 write 트랜잭션에 대해 Realm은 다음과 같은 여러 작업을 수행한다.
//• Commit 하기 전에 트랜잭션의 유효성을 검사한다.
//• 새 트랜잭션의 병합이 성공했는지 확인하기 전에 파일의 일관성을 확인한다.
//• 유효한 경우, 변경 알림을 모든 옵저버에게 보낸다.
//• 동일한 파일에 접근하는 모든 스레드의 Realm 스냅 샷을 새로 고침한다.
//적은 양의 데이터의 트랜잭션은 오버헤드를 무시해도 좋으나, 초당 수 천 건의 트랜잭션이 발생할 시에는 batch를 고려해야 한다.

