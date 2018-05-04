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

private func wordsList() -> [(String, String)] {
  return [("Cuaderno", "Notebook\nElla tiene muchos cuadernos."),
          ("Casa", "House\nNuestra familia vive en una gran casa"),
          ("Aprender", "To learn\nMe gusta aprender"),
          ("Hacer", "To do\nEmpecé a hacer yoga"),
          ("Tren", "Train\nEl viaje en tren es muy rápido"),
          ("Playa", "Beach\n¡Vamos a la playa!"),
          ("Pelota", "Ball\nSu regalo de cumpleaños es una nueva pelota")]
}

struct Tools {
  //앱과 함께 배포되는 번들 Realm을 자동으로 생성하는 클래스
  static func runIfNeeded() {
    guard ProcessInfo.processInfo.environment["SIMULATOR_UDID"] != "", ProcessInfo.processInfo.environment["TOOLING"] == "1" else {
      //환경 변수 SIMULATOR_UDID 설정. 응용 프로그램이 시뮬레이터에서 실행 중이어야 한다.
      //TOOLING은 FlashCardsTooling 대상에서 설정한 환경 변수인 1로 설정
      //Xcode - Product ▸ Scheme ▸ Edit Scheme의 Run 액션 아래에 추가 옵션에 사용자 정의 변수가 표시되어 있다. p.173
      return
    }
    
    createBundledWordsRealm()
    createBundledSetsRealm()
    exit(0) //번들을 생성하는 것이 목표이므로, 앱을 실행할 필요는 없다. 상태코드 0(성공)으로 exit() 호출하여 앱 종료
  }

  private static func createBundledWordsRealm() {
    let conf = Realm.Configuration(fileURL: try! Path.inDocuments("tooling-bundledWords.realm"), deleteRealmIfMigrationNeeded: true, objectTypes: [WordOfDayList.self, Entry.self])
    //tooling-bundledWords.realm로 Configuration
    let newWordsRealm = try! Realm(configuration: conf)
    let list = wordsList().map(Entry.init)
    
    try! newWordsRealm.write {
      newWordsRealm.deleteAll()
      newWordsRealm.add(WordOfDayList(list: list))
    }
    
    print("""
      *
      * Created: \(newWordsRealm.configuration.fileURL!)")
      *
      """)
  }

  private static func createBundledSetsRealm() {
    let conf = Realm.Configuration(fileURL: try! Path.inDocuments("tooling-bundledSets.realm"),
                                   objectTypes: [FlashCardSet.self, FlashCard.self])
    let newBundledSetsRealm = try! Realm(configuration: conf)

    let set1Cards = downloadableSets["Numbers"]!
                    .map { ($0[0], $0[1]) }
                    .map(FlashCard.init)

    let set1 = FlashCardSet("Numbers", cards: set1Cards)
    let set2 = FlashCardSet("Colors", cards: [])
    let set3 = FlashCardSet("Greetings", cards: [])

    try! newBundledSetsRealm.write {
      newBundledSetsRealm.deleteAll()
      newBundledSetsRealm.add([set1, set2, set3])
    }

    print("""
    *
    * Created: \(newBundledSetsRealm.configuration.fileURL!)
    *
    """)
  }
}

//Real Studio에서 객체 스키마를 정의하고, 수동으로 모든 데이터를 입력하여 번들 파일을 수동으로 만들 수 있지만, 자동으로 만드는 도구가 있다.
//JSON, CSV, 일반 텍스트와 같은 다른 형식의 데이터를 객체로 변환하고 이를 Realm 파일로 저장하여 앱과 함께 제공해야 하는 경우에도, 이런 도구가 필요하다.

