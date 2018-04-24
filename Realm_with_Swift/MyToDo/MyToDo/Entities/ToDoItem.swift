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

@objcMembers class ToDoItem: Object { //Realm Object는 Object(Realm)의 하위 클래스가 되어야 한다.
  //Object는 모든 Realm의 back-end data entity가 상속해야 하는 기본 클래스이다.
  //또한 이 클래스의 모든 속성은 동적(dynamic)으로 정의되어야 한다.
  enum Property: String {
    case id, text, isCompleted
  }

  dynamic var id = UUID().uuidString //UUID를 사용하면 고유한 식별자를 자동으로 쉽게 생성할 수 있다.
  dynamic var text = ""
  dynamic var isCompleted = false
  //dynamic으로 선언해, Realm은 데이터에 자동으로 매핑한다.
  //프로그램이 런타임 시에 어떤 메서드와 프로퍼티를 참조할 지 결정한다.
  //Model class는 앱의 코드와 디스크에 저장된 데이터 사이의 프록시 역할을 한다. p.34
  //Realm에서 변수 선언 시 dynamic이 "필수"이다.
  //dynamic키워드는 모델 변수에 대한 변경 사항을 Realm에 알리고, 결과적으로 이를 데이터베이스에 반영할 수 있도록 허용한다.
  
  //런타임 시에 Objective-C를 사용하여 메시지를 전송한다.
  //http://zeddios.tistory.com/296

  override static func primaryKey() -> String? {
    //Realm은 primaryKey()를 호출해(부모 클래스 메서드 오버라이드), 객체의 기본 키로 사용할 속성을 결정한다.
    //기본 키는 DB 객체를 식별하는 데 사용하는 고유한 값이다.
    return ToDoItem.Property.id.rawValue //UUID의 값을 키로 설정한다.
  }

  convenience init(_ text: String) {
    self.init()
    self.text = text
  }
}

// MARK: - CRUD methods

extension ToDoItem {
  static func all(in realm: Realm = try! Realm()) -> Results<ToDoItem> {
    //Realm을 서로 다른 버킷으로 분리할 수도 있기에 첫 번째 매개변수로 Realm 객체를 받는다.
    return realm.objects(ToDoItem.self) //objects(_)로 특정 유형의 객체를 가져올 수 있다.
      //Realm에서 모든 task를 가져온다. //default
      .sorted(byKeyPath: ToDoItem.Property.isCompleted.rawValue) //주어진 속성, 키 경로 값으로 정렬
      //완료 여부로 정렬
    
    //동적으로 엑세스할 수 있는 Results<ToDoItem> 반환
  }
  
  @discardableResult //반환형이 없을 수 있다. //외부에서 반환받은 객체를 사용하지 않을 때 유용하다.
  static func add(text: String, in realm: Realm = try! Realm()) -> ToDoItem {
    //Realm을 따로 지정하지 않으면 default Realm 객체로
    let item = ToDoItem(text) //객체 생성
    
    try! realm.write { //트랙젝션 생성
      realm.add(item) //객체 추가
    }
    
    return item
  }
  
  func toggleCompleted() {
    guard let realm = realm else { return } //Realm의 Object 타입에는 기본적으로 realm 변수가 있다.
    
    try! realm.write { //트랜젝션 생성
      isCompleted = !isCompleted //체크를 토글한다.
    } //트랜젝션이 성공적으로 커밋되면, 변경 사항은 디스크에 유지되고, observe를 통해, 변경에 대한 알림이 전파된다.
  }
  
  func delete() { //이미 UITableViewDelegate에서 스와이프로 삭제가 추가되어 있다.
    guard let realm = realm else { return }
    
    try! realm.write { //트랜젝션 생성
      realm.delete(self)
    } //write 트랜젝션을 생성하지 않고, 객체를 수정하면, 예외가 발생한다. write 트랜젝션 내에서만 객체를 수정할 수 있다.
  }
}

//Realm Object는 기본적으로 표준 DB 모델이며, 일반 class와 비슷하다.
//다른 DB처럼 추가적인 코드를 통해 파싱할 필요가 없다.
