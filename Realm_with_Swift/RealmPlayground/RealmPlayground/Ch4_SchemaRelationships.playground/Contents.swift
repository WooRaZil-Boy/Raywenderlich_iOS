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

// Setup
let realm = try! Realm(
  configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))

print("Ready to play!")

//To-one relationships
//To-one 관계는 object link라고도 불리며, 1:1 관계를 나타낸다.
//이 유형의 관계로 다른 Realm 객체를 가리키는 속성을 정의할 수 있다.
class Person: Object {
    //한 사람(Person)이 많은 RepairShop의 담당자일 수 있다.
    @objc dynamic var name = ""
    
    convenience init(_ name: String) {
        self.init()
        self.name = name
    }
}

class RepairShop: Object {
    //각 RepairShop은 한 명의 담당자(Person)을 가진다.
    @objc dynamic var name = ""
    @objc dynamic var contact: Person?
    //다른 Realm 객체와 연결된 관계를 만들 때 객체의 속성은 optional이어야 한다.
    //많은 다른 객체가 동일한 Person을 가리킬 수도 있다. p.73
}

//각 RepairShop은 한 명의 담당자(Person)을 가진다.
//한 사람(Person)이 많은 RepairShop의 담당자일 수 있다.
//따라서 모든 RepairShop 각 Person과 연결되며,
//이는 객체 포인터가 메모리에서 작동하는 원리와 비슷하다.
//RepairShop에 Person의 정보를 직접 저장하는 대신 이렇게 연결하도록 하면
//데이터 일관성을 얻을 수 있다. 링크된 Person의 변경 사항은 대상에 반영된다.
//모델의 스키마 모델은 p.71

let marin = Person("Marin")
let jack = Person("Jack")

let myLittleShop = RepairShop()
myLittleShop.name = "My Little Auto Shop"
myLittleShop.contact = jack
//Realm의 Object는 클래스이다. 따라서 위의 코드에서 할당하면, jack 객체는 복사되는 게 아니라
//포인터가 인스턴스를 가리키는 것처럼 디스크에 저장된 jack을 가리키는 설정을 한다. p.73
//Realm에서 jack을 삭제하면, 참조가 없으지므로 contact 속성이 nil이 된다.
//contact에 다른 Person 객체를 할당하거나 직접 nil을 할당할 수도 있다.
print(myLittleShop.contact?.name ?? "n/a")
//nil coalescing으로 값이 존재하지 않을 때 대체 값을 지정해 줄 수 있다.
//조건이 맞는다면 guard를 사용해 줄 수도 있다.
//guard let name = myLittleShop.contact?.name else { return }
//print(name)

//relationship이 관련된 객체의 Lifecycle을 관리하지 않기 때문에
//모든 객체를 수동으로 생성하고 삭제해야 한다.
//ex. Realm에서 myLittleShop 객체를 삭제해도, jack은 삭제되지 않는다.
//다른 객체에서 쓰이고 있을 수도 있기 때문이다. Realm은 앱의 논리에 어떤 가정도 하지 않는다.
//따라서 myLittleShop 객체 삭제 후, jack 객체가 필요없다면 수동으로 삭제해야 한다.

//동일한 Realm에 위치하는 Realm 객체 간에만 relationship을 만들 수 있다.
//다른 파일의 객체 간이나 파일 기반 Realm, 메모리 내에서는
//relationship을 일반적으로는 만들 수 없다(해결할 방법은 있다).

class Car: Object {
    @objc dynamic var brand = ""
    @objc dynamic var year = 0
    
    // Object relationships
    @objc dynamic var owner: Person?
    @objc dynamic var shop: RepairShop?
    
    //To-many relationships (for objects)
    let repairs = List<Repair>()
    //List(Realm의 List)는 @objc dynamic이 필요하지 않다.
    //Realm에서 사용하는 List로, 메서드로 해당 요소에 액세스할 수 있다.
    //새 Car 객체를 생성하면 빈 리스트로 생성된다.
    
    //To-many rela<onships (for values)
    let plates = List<String>() //번호판
    let checkups = List<Date>() //검진 날짜
    //DB 사양이 차후에 변경되고, 더 많은 관련 정보를 추가해야 할 때, 쉽게 사용할 수 있다.
    //두 속성 모두 기본 Swift 유형
    //values 타입의 List는 objects 타입과 달리, 요소를 제거하면 해당 요소는 즉시
    //메모리와 디스크에서 사라진다. objects 타입에서는 포인터이므로 List에서 삭제하더라도
    //Realm에는 남아 있다.
    
    //Using a list of strings to reference other objects
    let stickers = List<String>()
    //Sticker 객체에 직접 연결하는 대신 Sticker의 Id를 List에 String으로 저장한다.
    //위의 repairs와 달리 기본형으로 List 생성
    //같은 Realm 파일 내에 존재하지 않는 다른 곳에서 참조하기 위해 구현하는 가장 쉬운 방법.
    
    convenience init(brand: String, year: Int) {
        self.init()
        
        self.brand = brand
        self.year = year
    }
    
    override var description: String {
        return "Car {\(brand), \(year)}"
    }
}

//전체 스키마는 p.75

class Repair: Object {
    @objc dynamic var date = Date()
    @objc dynamic var person: Person?
    
    convenience init(by person: Person) {
        self.init()
        
        self.person = person
    }
}

let car = Car(brand: "BMW", year: 1980)

Example.of("Object relationships") {
    car.shop = myLittleShop
    car.owner = marin
    
    print(car.shop == myLittleShop) //같은 객체이므로 true
    print(car.owner!.name)
}

//To-one relationships as object inheritance
//Realm 객체도 계층 구조를 만들어야 할 때가 있지만, Realm은 객체 상속을 지원하지 않는다.
//따라서 합성을 통해 상속을 구현해야 한다.
class Vehicle: Object {
    @objc dynamic var year = Date.distantPast
    @objc dynamic var isDiesel = false
    
    convenience init(year: Date, isDiesel: Bool) {
        self.init()
        
        self.year = year
        self.isDiesel = isDiesel
    }
}

class Truck: Object {
    @objc dynamic var vehicle: Vehicle?
    @objc dynamic var nrOfGears = 12
    @objc dynamic var nrOfWheels = 16
    
    convenience init(year: Date, isDiesel: Bool, gears: Int, wheels: Int) {
        self.init()
        
        self.vehicle = Vehicle(year: year, isDiesel: isDiesel)
        self.nrOfGears = gears
        self.nrOfWheels = wheels
    }
}
//이런 식으로 내부에 포인터를 만들어 사용하는 것이 간단한 해결책이다.
//class Truck: Vehicle 이런 식으로 되는 것 같은데??




//To-many relationships (for objects)
//일대일 realationship 외에도 다른 객체 콜렉션에 링크를 걸 수 있다.
//위의 자동차 수리 DB에서, 한 대의 자동차에서 수행된 모든 수리 목록을 추가해야 한다.
//이 경우에는 Realm의 List를 사용해서 Car를 Repair 객체 컬렉션에 연결해야 한다.
//List는 동일한 유형의 Realm 객체에 대한 포인터가 들어있는 정렬 컬렉션이다.
//List는 객체를 복사하거나 관리하지 않고, 단순히 포인터의 정렬된 콜렉션이므로 효율적이다.
Example.of("Adding Object to a different Object's List property") {
    car.repairs.append(Repair(by: jack)) //List에 단일 객체 추가
    car.repairs.append(objectsIn: [ //리스트에 다중 객체 추가
        Repair(by: jack),
        Repair(by: jack),
        Repair(by: jack)
        ])
    
    print("\(car) has \(car.repairs.count) repairs")
    //append한 순서대로 들어간다.
}

Example.of("Adding Pointer to the Same Object") {
    let repair = Repair(by: jack)
    
    car.repairs.append(repair)
    car.repairs.append(repair)
    car.repairs.append(repair)
    car.repairs.append(repair) //동일한 객체를 여러번 추가할 수도 있다.
    
    print(car.repairs)
}




//Managing List elements
//append 외에도 요소를 삽입하는 여러 메서드가 있다.
//• List.insert(_:at:) : 지정된 인덱스에 객체 삽입
//• List.insert(contetnsOf:at:) : 지정된 인덱스에 객체 컬렉션 삽입
//• List.move(from:to:) : 요소 이동
//• List.removeFirst() : 첫 요소 삭제
//• List.removeFirst(number:) : 첫 숫자 요소 삭제
//• List.removeLast() : 마지막 요소 삭제
//• List.removeLast(number:) : 마지막 숫자 요소 삭제
//• List.remove(at:) : 해당 인덱스의 요소 삭제
//• List.removeAll() : 모든 요소 삭제
//• List.removeSubrange(bounds:) : 해당 범위 요소 삭제




//Aggregate functions
//List에는 다양한 메서드 들이 있는데, 유용한 메서드들은 다음과 같다.
//• min(ofProperty:) : 최소값. 숫자 형식(Int, Float, Double 등) 및 날짜에서만 작동
//• max(ofProperty:) : 최대값. 숫자 형식(Int, Float, Double 등) 및 날짜에서만 작동
let firstRepair: Date? = car.repairs.min(ofProperty: "date")
let lastRepair: Date? = car.repairs.max(ofProperty: "date")
//타입을 Date?로 명시해 줘야 한다. 그래야 Realm은 이런 집계 메서드의 반환형을 유추한다.

//• sum(ofProperty:) : 속성의 합
//• average(ofProperty:) : 속성의 평균




//Performance
//List는 유지 관리 및 작업이 쉽고, 효율적이므로 적극적으로 사용해야 한다.
//ex. 사용자가 UI 토글 시, 여러 속성을 저장해야 할 때, DB에서가 아닌 List에서
//토글 시마다 속성을 정렬해 준다. 실제로 표시하기 전까지는 정렬을 수행할 필요가 없다.
//대용량의 데이터 집합의 경우 전체 DB를 쿼리하는 대신 List를 사용하면 성능이 향상된다.




//To-many rela<onships (for values)
//List는 객체에 대한 포인터 뿐 아니라, 일반 Swift Array처럼 Value 타입을 관리할 수도 있다.
//Value 유형으로 List에 저장할 수 있는 유형은 다음과 같다.
//Bool, Int, Int8, Int16, Int32, Int64, Float, Double, String, Data, Date
//values 타입의 List는 objects 타입과 달리, 요소를 제거하면 해당 요소는 즉시
//메모리와 디스크에서 사라진다. objects 타입에서는 포인터이므로 List에서 삭제하더라도
//Realm에는 남아 있다.
Example.of("Adding Primitive types to Realm List(s)") {
    //String
    car.plates.append("WYZ 201 Q")
    car.plates.append("2MNYC0DZ")
    
    print(car.plates)
    //출력 시에, 데이터 타입을 소문자로 잘못 출력하는 버그(String -> string 등)가 있다.
    print("Current registration: \(car.plates.last!)")
    
    //Date
    car.checkups.append(Date(timeIntervalSinceNow: -31557600))
    car.checkups.append(Date())
    
    print(car.checkups)
    print(car.checkups.first!)
    print(car.checkups.max()!)
}




//Using a list of strings to reference other objects
//다른 객체에 대한 to-many relationship을 만들 때에는 List를 사용하기만 하면 된다.
//List는 동일한 Realm의 Object에 대한 링크만 관리한다. 앱이 커지면 Realm 파일을
//여러 개 만들어야 할 때도 있고, 읽기 전용으로 로드되거나 서버와 동기화 되거나 암호화 될 수도
//있다. 이런 경우에는 다른 Realm 파일 객체를 가리키도록 해야 한다(여기서 하진 않는다 나중에).
class Sticker: Object { //위반 딱지
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var text = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(_ text: String) {
        self.init()
        
        self.text = text
    }
}
//Car 객체와 같은 Realm 파일에 Sticker 객체를 저장할 때, 위의 Car에서 구현 했듯이
//let stickers = List<Sticker>() 와 같이 객체에 대한 참조를 유지하기 위해 새 List를
//추가하기만 하면 된다. 하지만 객체를 직접 참조할 수 없는 경우(다른 Realm 파일이나 메모리),
//다른 방식으로 접근해야 한다. List<Sticker>() 가 아닌 List<String>()으로 구현한다.

Example.of("Referencing objects from a different Realm file") {
    // let's say we're storing those in "stickers.realm"
    let sticker = Sticker("Swift is my life")
    //default Realm이 아닌 stickers.realm이라는 다른 Realm 파일에 저장한다고 가정
    
    car.stickers.append(sticker.id) //Sticker 객체가 아닌 Sticker의 id를 저장
    print(car.stickers)
    //이런 식으로 다른 Realm 파일에서 실제 객체를 가져올 수 있다(추가적인 과정이 필요하다).
    
    try! realm.write { //현재 Realm 파일(default)에 쓴다.
        realm.add(car)
        realm.add(sticker)
    } //다른 Realm파일에 저장된 것으로 가정
    
    print("Linked stickers:")
    print(realm.objects(Sticker.self) //Stiker 유형의 모든 객체 쿼리
        .filter("id IN %@", car.stickers)) //id 값이 해당하는 객체를 필터링
    //전체 스키마는 p.86
}
