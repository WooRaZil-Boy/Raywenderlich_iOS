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
import CoreLocation

// Setup
let realm = try! Realm(configuration:
  Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))

print("Ready to play...")

// Playground
class Car: Object { //클래스 정의 //Realm 클래스는 Object를 상속해야 한다.
    //앱이 실행될때 Realm은 모든 클래스를 검사해 Realm의 Object를 상속하는 클래스를 찾는다.
    //이 클래스들의 목록은 디스크 또는 메모리에 데이터 스키마로 유지된다.
    //기본적으로 Realm 객체를 여러 개 구성하지 않는다면,
    //Documents 폴더의 기본 Realm에 모든 객체를 저장한다.
    
    @objc dynamic var brand = ""
    @objc dynamic var year = 0
    //Realm 클래스의 변수는 dynamic이 되어야 한다.
    //@objc dynamic은 런타임 시에 동적으로 속성에 엑세스 할 수 있게 한다.
    //이를 통해 Realm 클래스는 DB에 대해 맞춤형 기본 설정을 할 수 있으며,
    //데이터를 디스크나 메모리에서 읽고 쓰는 것을 자동으로 관리한다.
    //ex. 여기서 brand 변수에 접근하면 Realm에서 직접 데이터를 가져온다.
    //    일반 객체라면, 메모리에 불러와서 값을 가져왔을 것이다. p.52
    
    convenience init(brand: String, year: Int) {
        self.init()
        self.brand = brand
        self.year = year
    }
    
    override var description: String {
        return "🚗 {\(brand), \(year)}"
    }
}

Example.of("Basic Model") { //Helper Method
    let car1 = Car(brand: "BMW", year: 1980) //객체 생성
    print(car1)
    
    //현재에는 Realm에 추가되지 않고 일반 Swift 객체처럼 작동한다.
    //Realm에서 관리되지 않으므로 이 클로저가 종료될 때 해제된다.
    
    //이러한 객체를 unmanaged 혹은, detached 객체라고 한다.
    //Realm에 객체를 추가하면, Realm에서 해당 객체를 관리하고 동작을 구현한다.
    //디스크에 저장될 수 있으며, write 트랜잭션 내에서만 수정할 수 있다.
}

class Person: Object {
    //Object-type properties 에는 String, Date, Data 3가지 가 있다.
    //RealmSwift는 Objective-C Realm 프레임워크를 래핑한 것이다.
    //따라서 Objective-C 특성을 기반으로 하는 Swift 코드가 일부 존재 한다.
    //그 중 주의해야 할 점은 개체의 유형과 Realm 개체에 저장할 수 있는 형식 간의 차이이다.
    //String, Date, Data 등의 유형은 Objective-C의 NSObject 하위 클래스이므로
    //Swift에서도 문제 없으나, nil 혹은 포인터 등의 경우에는 optional을 고려해야 한다.
    
    //String
    @objc dynamic var firstName = "" //non-optional
    //Realm에서 모든 non-optional 타입은 기본값을 가져야 한다.
    @objc dynamic var lastName: String? //optional
    //optional이므로 기본값이 필요하지 않다.
    //16MB 이상의 String은 저장할 수 없다.
    
    //Date
    @objc dynamic var born = Date.distantPast //non-optional
    //Realm에서 모든 non-optional 타입은 기본값을 가져야 한다.
    //distantPast는 먼 과거의 값. 0001-01-01 00:00:00 +0000
    //distantFuture도 있다. 4001-01-01 00:00:00 +0000
    @objc dynamic var deceased: Date? //optional
    
    //Data
    @objc dynamic var photo: Data?
    //DB에 Data를 저장하는 것은 일반적으로는 의미가 없는 일이다.
    //DB 파일이 불필요하게 커질 수 있으므로 되도록이면 Data 타입으로 저장하지 않는게 좋다.
    //디스크에 저장하고, path를 저장하는 것이 일반적
    //16MB 이상의 데이터는 저장할 수 없다.
    
    
    
    
    //Primitive-type properties는 일반적으로 Swift 객체이다.
    //하지만, Realm 특성상 Objective-C의 유형으로 대신 표현된다.
    //이러한 유형의 특징으로는
    //• Objective-C에서는 프리미티브가 nil이 될 수 없으므로
    //  optional을 직접 선언 할 수 없다.
    //• 대신 Switf의 optional을 모방한 RealmOptional이라는 제네릭 형식으로 래핑한다.
    
    //Xcode 9.3에서는 RealmOptional이 Playground에서 작동하지 않아
    //optional을 사용하지 않아도 되지만, 응용 프로그램 프로젝트에서는 꼭 써야 한다.
    
    //Bool
    @objc dynamic var isVIP: Bool = false //non-optional
    //기본값을 설정해 줘야 한다. non-optional 선언은 Object-type properties와 같다.
//    let allowsPublication = RealmOptional<Bool>() //Optional Bool
    //Optional Bool을 추가하려면 RealmOntional 유형으로 래핑해야 한다.
    //RealmOptional을 사용하면 value 속성을 사용해서 기본값을 가져오거나 설정해야 한다.
    //이렇게 optional로 선언을 하면, true, false, nil의 값을 가질 수 있다.
    //RealmOptional도 기본값을 가질 수 있다. 생성자의 파라미터를 이용해 설정하면 된다.
    //allowsPublication = RealmOptional<Bool>(true)
    
    //Int, Int8, Int16, Int32, Int64
    @objc dynamic var id = 0 // Inferred as Int
    @objc dynamic var hairCount: Int64 = 0
    //Realm은 Int, Int8, Int16, Int32, Int64를 지원한다.
    //특정 유형을 사용해야 할 때는 명시적으로 선언해 줘야 한다.
    //optional을 선언하려면, RealmOptional 래퍼를 사용해야 한다.
    
    //Float, Double
    @objc dynamic var height: Float = 0.0
    @objc dynamic var weight = 0.0 // Inferred as Double
    //Float, Double도 나머지 기본 유형과 동일하게 작동한다.
    //CGFloat는 지원되지 않는다(플랫폼 간에 표현이 달라질 수 있으므로).
    
    
    
    
    //Custom types이 필요할 때, 되도록이면 위의 타입들을 활용해
    //computed properties를 사용해 주는 것이 좋다.
    //Custom type을 선언하려면 데이터를 serialize와 deserialize 해 줘야 한다.
    
    //Xcode 9.3에서는 RealmOptional이 Playground에서 작동하지 않아,
    //아래 코드들이 오류가 난다. 앱에서는 잘 작동한다.
    
    //Wrapping CLLocation
//    //Compound property
//    private let lat = RealmOptional<Double>()
//    private let lng = RealmOptional<Double>()
//    //private로 하면 외부에서 액세스 할 수 없게 된다.
//    //CLLocation은 각각 위도와 경도를 Double로 저장할 수 있다.
//    //Realm Object에는 위의 2개의 Double 속성을 추가하고,
//    //앱에서 사용할 때는 lastLocation을 활용할 수 있다. p.58
//
//    var lastLocation: CLLocation? {
//        //lat, lng는 외부에서 엑세스할 수 없고, lastLocation을 통해 접근한다.
//        get {
//            guard let lat = lat.value, let lng = lng.value else {
//                //옵셔널 해제
//                return nil
//            }
//
//            return CLLocation(latitude: lat, longitude: lng)
//            //CLLocation으로 반환
//        }
//
//        set {
//            guard let location = newValue?.coordinate else {
//                //위도, 경도 정보를 가져 올 수 없으면 종료
//                lat.value = nil
//                lng.value = nil
//                return
//            }
//
//            lat.value = location.latitude
//            lng.value = location.longitude
//            //위도, 경도 정보를 각각 저장
//        }
//    }
//    //이런 방식으로 Realm이 제공하는 데이터 타입을 래핑해 사용할 수 있다.
    
    //Enumerations
    enum Department: String { //열거형을 꼭 클래스 내에서 선언할 필요는 없다.
        case technology
        case politics
        case business
        case health
        case science
        case sports
        case travel
        //String을 사용하므로, 모든 case의 value에 case 명과
        //동일한 문자열 값이 할당된다(rawValue).
        //raw value가 없는 enum의 경우, Realm에서 지원하는 유형을 사용해
        //serialize, deserialize 할 수 있도록 메서드를 구현해야 한다.
    }
    
    @objc dynamic private var _department = Department.technology.rawValue
    //Realm DB에 저장될 값 //String
    var department: Department { //외부적으로 앱에서 사용될 변수
        get { return Department(rawValue: _department)! }
        set { _department = newValue.rawValue }
    }
    
    
    
    
    //Computed properties
    //클래스에 Computed properties를 추가해 커스텀 서식이나 기타 기능을 제공할 수 있다.
    //Computed properties는 setter가 없으므로, Realm은 해당 속성을 관리하지 않는다.
    var isDeceased: Bool {
        return deceased != nil
    }
    
    var fullName: String {
        guard let last = lastName else { //lastName이 nil인 경우
            return firstName
        }
        
        return "\(firstName) \(last)"
    }
    
    
    
    
    //Convenience initializers
    //Object 클래스에 convenience init를 구현해 초기화하고 안전성을 높이는 것이 좋다.
    convenience init(firstName: String, born: Date, id: Int) {
        self.init()
        
        self.firstName = firstName
        self.born = born
        self.id = id
    }
    
    
    
    
    //Meta information
    //Object클래스에서 재정의하여 메타 정보를 가져올 수 있는 몇 가지 메서드가 있다.
    //자주 사용되는 메타 정보 메서드는 세 가지가 있다(모두 static).
    //Primary key, Indexed properties, Ignored properties
    
    //Primary key
    //객체의 속성 중 하나를 기본키로 설정할 수 있다. ID 등의 고유 속성이 기본키가 될 수 있다.
    //기본 키는 개체를 고유하게 설정하고, DB 객체를 빠르게 찾거나 수정할 수 있게 한다.
    //기본 키는 변경 불가능하다.
    @objc dynamic var key = UUID().uuidString //UUID로 유일한 값을 가져온다.
    //기본적으로 key, id 등의 적합한 String 속성을 추가한 다음
    override static func primaryKey() -> String? {
        //primaryKey()메서드를 재정의하여 기본 키 속성의 이름을 반환한다.
        //Realm 객체는 기본 키가 없는게 default 이므로,
        //primaryKey()의 기본 구현은 nil을 반환한다.
        return "key"
    }
    //클래스에 키를 추가하면, DB에 있는 각 클래스에 대해 자동으로 생성된 고유 식별자를 얻는다.
    //기본키를 사용해 밑의 방식처럼 특정 개체를 검색할 수 있다.
//    let myPerson = realm.object(ofType: Person.self, forPrimaryKey: "89967121-61D0-4874-8FFF-E6E05A109292")
    
    //일반적으로 DB는 자동 증가 시퀀스(auto-incrementing ID)를 사용해
    //순차적으로 정수를 입력해 기본키로 사용하기도 한다.
    //이는 보안적인 측면에서 문제가 있지만, 쉽고 빠르게 구현할 수 있었다.
    //이 방식은 그동안 사용한 일반적인 DB들이 서버를 기반으로 기본 키의 자동 생성을 처리했기
    //때문에 자주 사용됐었다. 하지만, 클라이언트에서는 이 기능을 사용할 필요가 없다.
    //모바일 응용 프로그램, Realm에서는 이런 방식(자동 증가 시퀀스)을 지양하는 것이 좋다.
    
    //Indexed properties
    //Realm 객체의 프로퍼티에 빠르게 접근할 수 있도록 인덱스를 작성할 수도 있다.
    //해당 프로퍼티(속성)을 인덱스(색인)에 추가해 쿼리할 때 DB 검색 속도를 높일 수 있다.
    override static func indexedProperties() -> [String] {
        //인덱싱을 하려면 indexedProperties 메서드를 오버라이드 해야 한다.
        return ["firstName", "lastName"] //인덱싱할 객체의 속성명을 반환
        //인덱스를 추가하면, DB 필터링하거나 쿼리 시에 시간이 향상되지만,
        //인덱스를 다시 작성할 때 DB 파일 크기가 증가하고 성능이 약간 저하된다.
        //따라서 앱에서 반복적으로 쿼리하는 속성에 대해서만 인덱싱해야 한다.
    }
    //다른 SQL 기반 DB에서는 성능향상을 위해 인덱싱이 거의 필수적이었다.
    //하지만, Realm에서는 인덱싱을 권장하지 않는다. 그 이유는
    //1. Realm은 모바일 장치에서 실행되기에, CPU와 메모리 자원이 한정적이다.
    //2. Realm은 객체 링크가 있어, 객체에서 다른 객체로 링크를 따라가는 것이 더 효율적이다.
    //   이는 다른 SQL에서 필요한 전체 객체를 찾기 위해 DB를 조회하는 것보다 훨씬 효율적이다.
    
    //Ignored properties
    //일부 객체 속성을 무시하도록 한다. Realm 객체는 Swift 클래스의 인스턴스이기도 하므로
    //Realm에서 유지하지 않아도 되는 속성을 무시해 줄 수 있다.
    //이 방법에는 inaccessible setter와 custom ignored properties가 있다.
    
    //Properties with inaccessible setters
    //Realm은 Objective-C 클래스의 introspection을 사용해 프로퍼티 목록을 가져와
    //관리한다. 따라서 Objective-C를 기반으로 한 Realm 클래스에 액세스 할 수 없거나
    //액세스 가능한 setter가 없는 모든 속성(상수)은 자동으로 무시된다.
    let idPropertyName = "id" //상수, 값을 변경할 수 없다. 생성하는 클래스마다 동일한 값
    //따라서 Realm이 이 값을 클래스 별로 따로 유지하는 것은 의미가 없다.
    var temporaryId = 0 //변수, 값을 변경할 수 있다.
    //변수 이므로 setter가 있지만, dynamic으로 선언되지 않았다.
    //따라서 클래스의 슈퍼 클래스(Person의 부모 클래스. Object)가 액세스 할 수 없다.
    //@objc dynamic으로 선언해야 접근할 수 있다.
    //Realm이 이 속성을 무시하는 지 확인하려면, 콘솔에 인스턴스를 출력해 보면 된다.
    //print(person)
    
    //Custom ignored properties
    //@objc dynamic으로 설정된 접근 가능한 속성도 커스텀하게 무시할 수 있다.
    @objc dynamic var temporaryUploadId = 0
    //@objc dynamic으로 구현 되었기에, 기본적으로는 무시되지 않는다.
    override static func ignoredProperties() -> [String] {
        //Custom ignored properties를 구현하려면
        //ignoredProperties()를 오버라이드 해야 한다.
        return ["temporaryUploadId"]
    }
}

Example.of("Complex Model") {
    let person = Person(firstName: "Marin", born: Date(timeIntervalSince1970: 0), id: 1035) //객체 생성
    
    person.hairCount = 1284639265974
    person.isVIP = true
    //객체가 Realm에 추가되지 않은 이상 자유롭게 수정할 수 있다.
    //하지만, Realm에 추가되면, write 트랜잭션 내에서만 수정할 수 있다.
    
    print(type(of: person)) //객체 유형 반환
    print(type(of: person).primaryKey() ?? "no primary key")
    //기본 키를 정의하지 않았으므로 nil.
    print(type(of: person).className()) //객체의 이름 반환
    print(person) //Realm 객체가 제공하는 description 출력
    //콘솔에서 객체의 데이터를 빠르게 확인할 수 있다.
    //null로 출력되는 것을 nil로 착각하지 말것
    //private로 선언된 변수들도 출력이 된다(description이 클래스 내부에 있기 때문).
    //computed properties는 출력되지 않는다.
}

@objcMembers class Article: Object {
    //@objcMembers
    //속성을 선언할 때 @objc dynamic로 선언하고 들여쓰기 하는 것이 번거로울 수 있다.
    //Objective-C의 introspection을 자주 사용하는 프레임 워크에 대한 지원을 위해
    //@objcMembers라는 수정자가 있다. 클래스 선언 시에 @objcMembers를
    //설정하면 모든 멤버가 @objc로 정의되어 @objc를 따로 입력하는 번거로움을 줄일 수 있다.
    dynamic var id = 0
    dynamic var title: String?
    //모두 @objc dynamic으로 선언이 된다.
    
    //동적 디스패치는 성능 손실이 발생하므로 일반적으로 @objcMembers를 남용해선 안 된다.
    //하지만, Realm은 필수적으로 Objective-C 런타임 시에 동적 디스패치가 되어야 하므로
    //Realm의 객체의 경우에는 @objcMembers를 사용하는 것이 좋다.
}

Example.of("Using @objcMembers") {
    let article = Article()
    article.title = "New article about a famous person"
    
    print(article)
}


