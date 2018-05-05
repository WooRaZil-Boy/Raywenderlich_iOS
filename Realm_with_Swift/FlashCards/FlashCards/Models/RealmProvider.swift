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

struct RealmProvider {
  //실제 응용 프로그램을 만들 때 여러 개의 Realm 파일로 작업할 때가 있다.
  //그런 경우, 여러 Realm 파일에 대한 접근을 단순화하기 위해 클래스나 구조체를 사용하는 것이 편하다.
  //여기서는 RealmProvider 구조체가 그 역할을 한다.
  let configuration: Realm.Configuration
  //RealmProvider는 Realm.Configuration 위주로 래핑한다.
  //해당 configuration으로 Realm 인스턴스를 구성한다.
  
  var realm: Realm { //현재 Realm을 반환하는 computed property
    return try! Realm(configuration: configuration)
    //정확하게는 try!로 하면 안 된다.
    //Realm 파일을 열거나 쓸 때, 디스크 공간 부족, 파일 손상 등의 이유로 오류가 날 수 있기 때문.
  }
  
  internal init(config: Realm.Configuration) {
    configuration = config
  }
  
  
  
  
  private static let cardsConfig = Realm.Configuration(fileURL: try! Path.inLibrary("cards.realm"), schemaVersion: 1, deleteRealmIfMigrationNeeded: true, objectTypes: [FlashCardSet.self, FlashCard.self])
  //libraries 폴더의 cards.realm에 액세스. FlashCardSet과 FlashCard 객체로 되어 있는 Configuration p.161
  
  public static var cards: RealmProvider = { //RealmProvider에 대한 액세스 제공
    return RealmProvider(config: cardsConfig) //cardsConfig로 Realm 생성
    //RealmProvider.cards.realm에 액세스해서 기본 Realm과 함께 작업하고
    //필요 시에, RealmProvider.cards를 객체와 스레드에 전달할 수 있다.
  }()
  
  
  
  
  private static let bundledConfig = Realm.Configuration(fileURL: try! Path.inBundle("bundledSets.realm"), readOnly: true, objectTypes: [FlashCardSet.self, FlashCard.self])
  //bundledSets.realm에 액세스. FlashCardSet과 FlashCard 객체로 되어 있는 읽기 전용 Configuration
  
  public static let bundled: RealmProvider = {
    return RealmProvider(config: bundledConfig)
    //위의 cards 로직과 유사하다. 필요한 경우, 번들 Realm과 Configuration에 접근할 수 있다.
    //번들은 앱과 함께 제공되고, 처음 앱 실행 시 복사할 초기 데이터가 있으므로,
    //파일의 객체 스키마는 cards.realm과 동일하다.
  }()
  
  
  
  
  private static let wordOfDayConfig = Realm.Configuration(fileURL: try! Path.inBundle("bundledWords.realm"), readOnly: true, schemaVersion: 1, objectTypes: [WordOfDayList.self, Entry.self])
  //bundledWords.realm에 액세스. WordOfDayList과 Entry 객체로 되어 있는 읽기 전용 Configuration
  //WordOfDayList는 Entry 객체의 정렬된 List //p.166
  
  public static let wordOfDay: RealmProvider = {
    return RealmProvider(config: wordOfDayConfig)
  }()
  
  
  
  
  private static let settingsConfig = Realm.Configuration(fileURL: try! Path.inSharedContainer("settings.realm"), schemaVersion: 1, objectTypes: [Settings.self, Entry.self])
  //settings.realm에 액세스. Settings과 Entry 객체로 되어 있는 Configuration p.168
  //사용자가 오늘의 단어를 선택할 때마다 bundledWords.realm의 Entry 객체를 settings.realm으로 복사한다.
  //settings Realm 파일은 shared container에 있으므로, FlashCards 앱과 extension에서 모두 접근할 수 있다.
  
  public static var settings: RealmProvider = {
    if let realm = try? Realm(configuration: settingsConfig), realm.isEmpty {
      //비어 있는 경우에만 생성 //settings는 처음 액세스 될 때 한 번만 실행됙 때문에,
      //Realm에 최소 하나의 Settings 객체가 있는지 확인하고 생성.
      try! realm.write {
        realm.add(Settings())
      }
    }
    
    return RealmProvider(config: settingsConfig)
  }()

  //RealmProvider 래퍼는 Realm 인스턴스 또는 Configuration을 직접 작업하는 것에 비해 다음과 같은 장점이 있다.
  //• Realm의 구성을 중앙에서 관리할 수 있다.
  //• 스레드 간에 전달 할 수 있다.
  //• 앱에 필요한 각 Realm 파일에 대한 인스턴스 목록을 미리 정의할 수 있다.
  //• 생성자를 추가할 수 있다. 이를 통해, 지정된 Realm에 기본 데이터가 있는지 확인하거나 무결성 검사를 할 수 있다.
  
  //다양한 Configuration을 모두 추상화하여, API를 제공한다.
}

//최종 완성된 앱은 6개의 Realm 파일로 작동한다. 첫 프로젝트(Ch8)에서는 4개만 사용. p.160

//특정 종속성의 추상화해 central provider structure(RealmProvider)를 사용하면,
//코드 관리와 테스트 시에 유용하다.
