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

// setup
let realm = try! Realm(configuration:
  Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))
//메모리에 임시 Realm을 생성한다. 디스크에 쓴 것과 거의 유사하다.
try! TestDataSet.create(in: realm)

print("Ready to play!")

//스키마는 p.92
//Realm은 Results 클래스로 데이터를 가져오는 간소한 API가 있다.




//Realm Results
//Reulsts는 API로 lazy 데이터를 가져오는 lazy Swift의 콜렉션을 모방한 것이다.
//Realm에서 특정 유형의 모든 객체에 대한 액세스를 제공하고, 필터링, 정렬 등도 지원한다.
//Results를 사용하는 가장 강력한 이유는 lazy라는 것이다. 처음 요소에 액세스해야만
//리소스가 소비된다. 그 외의 특징은 Swift의 Array와 비슷하며, 변환도 쉽게 할 수 있다.




//Fetching all objects of a type
//앱이 여러 Realm에서 작동할 수 있으므로, 객체를 가져오는 API는 클래스 메서드이다.
//따라서 데이터가 있는 Realm을 언제나 알 수 있다.
//Realm에서 객체를 가져오는 API는 Realm.objects(_) 이다. 한 번의 하나의 유형만
//가져올 수 있으며, 객체의 link나 List에 액세스하면 다른 유형으로 이동할 수 있다.
Example.of("Getting All Objects") {
    let people = realm.objects(Person.self)
    let articles = realm.objects(Article.self)
    //특정 유형의 모든 객체 가져오기
    //결과는 각각 Results<Type>. lazy이므로 실제 접근하기 전에는
    //디스크에서 로드하거나 복사하지 않는다.
    
    print("\(people.count) people and \(articles.count) articles")
    //count : 현재 Result와 일치하는 객체의 수 반환. 없을 경우 0
    //여기서 count 속성을 사용하므로, 쿼리의 메타 데이터를 가져온다.
    //하지만 여전히, 메모리에 데이터를 로드하진 않는다.
    
    //UICollectionView이나 UITableView를 생각하면 된다. count는 미리 전달되지만,
    //각 객체의 세부 데이터는 표시하지 않고, 특정 셀이 요청될 때 가져온다.
    
    //Results의 객체는 정렬되어 있지 않다. objects(_)는 임의의 방식으로 객체를 가져온다.
    //Realm에 객체를 추가할 때, 추가된 순서대로 저장되지만, DB를 사용할 때 파일이 압축되고,
    //최적화되면서 해당 순서가 변경될 수 있다. 따라서 순서가 필요하면 따로 정렬을 해 줘야 한다.
}




//Fetching an object by its primary key
//Realm.object(ofType : forPrimaryKey :)로 키와 일치하는 객체를 찾는다.
Example.of("Getting an Object by Primary Key") {
    let person = realm.object(ofType: Person.self, forPrimaryKey: "test-key")
    //기본 키로 단일 객체를 가져온다. //결과가 없으면 nil
    
    if let person = person { //찾지 못하면 nil이므로 옵셔널 해제해줘야 한다.
        print("Person with Primary Key 'test-key': \(person.firstName)")
    } else {
        print("Not found")
    }
}




//Accessing objects in a result set
Example.of("Accessing Results") {
    let people = realm.objects(Person.self) //전체 Person객체 가져온다.
    
    print("Realm contains \(people.count) people")
    print("First person is: \(people.first!.fullName)") //첫 번째 객체
    print("Second person is: \(people[1].fullName)") //특정 인덱스 객체
    print("Last person is: \(people.last!.fullName)") //마지막 객체
    //컬렉션이 비어있을 수 있으므로 옵셔널이다. //인덱스 범위가 벗어나면 오류
    //Results 집합은 정렬되어 있지 않기 때문에, 실행 시 마다 결과가 달라질 수 있다.
    
    let firstNames = people.map { $0.firstName } //firstName만 추출해서
        .joined(separator: ", ") //, 로 연결 시킨다.
    //Functional Programming
    print("First names of all people are: \(firstNames)")
    
    let namesAndIds = people.enumerated() //(offset: Int, element: Person)
        .map { "\($0.offset): \($0.element.firstName)" }
        .joined(separator: ", ") //, 로 연결 시킨다.
    print("People and indexes: \(namesAndIds)")
}




//Results indexes
Example.of("Results Indexes") {
    let people = realm.objects(Person.self)
    let person = people[1] //인덱스를 사용해서 요소에 접근
    
    if let index1 = people.index(of: person) { //요소의 인덱스 가져오기
        //해당 객체가 존재하지 않으면 nil
        print("\(person.fullName) is at index \(index1)")
    }
    
    if let index2 = people.index(where: { $0.firstName.starts(with: "J") }) {
        //where로 특정 조건에 해당하는 요소의 인덱스를 가가져올 수 있다.
        //filter(_)의 특수화된 메서드.
        print("Name starts with J at index \(index2)")
    }
    
    if let index3 = people.index(matching: "hairCount < %d", 10000) {
        //NSPredicate를 이용해 필터링 할 수도 있다.
        //index(matching :)은 단일 NSPredicate를 파라미터로 사용한다.
        //index(matching:_...:)는 다수의 NSPredicate를 파라미터로 사용한다.
        //첫 번째로 일치하는 요소를 가져온다.
        print("Person with less than 10,000 hairs at index \(index3)")
    }
}




extension Person {
    //문자열을 사용해서 쿼리하면, 오타 등으로 인해 오류가 발생하기 쉽다.
    //NSPredicate를 구현해주는 오픈 소스 라이브러리도 있지만,
    //여기에선, 래핑하는 방법으로 구현한다.
    static let fieldHairCount = "hairCount"
    static let fieldDeceased = "deceased"
    
    static func allAliveLikelyBalding(`in` realm: Realm, hairThreshold: Int = 1000) -> Results<Person> {
        let predicate = NSPredicate(format: "%K < %d AND %K = nil", Person.fieldHairCount, hairThreshold, Person.fieldDeceased)
        //미리 정의된 상수로 NSPredicate을 만든다.
        //NSPredicate(format: "hairCount < %d AND deceased = nil", 1000)
    
        return realm.objects(Person.self).filter(predicate)
    }
}

//Filtering results
Example.of("Filtering") {
    let people = realm.objects(Person.self) //모든 객체
    //단순히 objects로 가져오는 것은 디스크에 쓰거나, 메모리에 올리지 않는다.
    //액세스해야 리소스가 소비된다. 따라서 액세스하기 전에 필터링 해 주면 리소스를
    //아끼면서 원하는 결과를 얻을 수 있다.
    print("All People: \(people.count)")

    let living = realm.objects(Person.self)
        .filter("deceased = nil") //deceased이 nil인 객체만 가져온다.
    print("Living People: \(living.count)")

    let predicate = NSPredicate(format: "hairCount < %d AND deceased = nil", 1000)
    //hairCount가 %d(1000)보다 작아야 하고, deceased가 nil이어야 한다.
    let balding = realm.objects(Person.self)
        .filter(predicate)
        //filter(_)의 변형으로, format 문자열 대신에
        //NSPredicate 객체로 더 안전하고 효율적으로 필터링할 수 있다.

    let baldingStatic = Person.allAliveLikelyBalding(in: realm)
    //realm을 파라미터로 전달하지 않으려면, 직접 Realm의 클래스에서 extension
    //해서 구현해야 한다. 이 방식은 여러 Realm을 사용할 때 문제가 있을 수 있다.
    //이 경우, Person 객체를 가져오지만, Realm 클래스에 메서드를 구현한 경우,
    //Person 객체가 하나도 없다면 런타임 오류가 난다.
    print("Likely balding people (via static method): \(baldingStatic.count)")
}




//More advanced predicates
Example.of("More Predicates") {
    let janesAndFranks = realm.objects(Person.self)
        .filter("firstName IN %@", ["Jane", "Frank"])
        //IN 키워드로 주어진 값 목록에서 필터링 할 수 있다.
        //firstName이 "Jane"이나 "Frank"인 요소 필터링
    print("There are \(janesAndFranks.count) people named Jane or Frank")
    
    let balding = realm.objects(Person.self)
        .filter("hairCount BETWEEN {%d, %d}", 10, 10000)
    //BETWEEN 키워드로 범위 사이의 값을 필터링할 수 있다.
    //hairCount가 10 ~ 1000(포함) 사이인 값을 필터링
    print("There are \(balding.count) people likely balding")
    
    let search = realm.objects(Person.self)
        .filter("""
                firstName BEGINSWITH %@ OR
                (lastName CONTAINS %@ AND hairCount > %d)
                """,
                "J", "er", 10000)
    //Swift 4.0 부터 긴 문자열을 """ """ 사이에 넣어 표현할 수 있다(다중 행 문자열).
    //J로 firstName이 시작하는 객체 이거나
    //lastName에 er이 포함되고 hairCount가 10000보다 많은 객체
    print("🔎 There are \(search.count) people matching our search")
}




//Sub-query predicates
Example.of("Subqueries") {
    let articlesAboutFrank = realm.objects(Article.self)
        .filter("""
                title != nil AND
                people.@count > 0 AND
                SUBQUERY(people, $person,
                      $person.firstName BEGINSWITH %@ AND
                      $person.born > %@).@count > 0
                """,
                "Frank", Date.distantPast)
    //더 복잡한 술어의 경우, 원래 술어와 일치하는 각 객체에서 별도의 술어를 실행하는
    //SUBQUERY를 사용할 수 있다.
    //SUBQUERY의 첫 매개 변수는 predicate를 실행하는 콜렉션 (Article의 people)
    //두 번째 매개 변수는 루프에서 사용할 가변 이름의 콜렉션 (people의 요소를 person으로)
    //세 번째 매개 변수는 predicate 이다.
    
    //title 이 nil 이면서
    //people의 집계 속성인 @count가 0 보다 커야 하고
    //SUBQUERY의 조건을 만족하는 @count가 0보다 커야 한다.
    //(people, $person, <predicate>)
    //  person의 firstName이 Frank로 시작해야 한다.
    //  person의 born이 Date.distantPast보다 커야 한다.
    
    //SUBQUERY 표현에 적용되는 유일한 오퍼레이터인 @count 사용할 경우
    //SUBQUERY(…).@count 표현은 반드시 상수와 비교돼야 한다.
    print("There are \(articlesAboutFrank.count) articles about frank")
}




//Predicates cheat-sheet p.102

//Predicate replacements
//• [property == %d] filter("age == %d", 30) replaces %d with 30 and matches if column called 'property' is equal to 30
//• [%K == %d] filter("%K == %d", "age", 30) replaces %K with 'age' and %d with 30 and matches if column 'age' equals 30

//Comparison operators (abbrev.)
//• [==] filter("firstName == 'John'") matches values equal to
//• [!=] filter("firstName != 'John'") matches values not equal to
//• [>, >=] filter("age > 30"), filter("age >= 30") matches values greater than (or equal) to
//• [<, <=] filter("age < 30"), filter("age <= 30") matches values less than (or equal) to
//• [IN] filter("id IN [1, 2, 3]") matches value from a list of values
//• [BETWEEN] filter("age BETWEEN {18, 68}") matches value in a range of values

//Logic operators (abbrev.)
//• [AND] filter("age == 26 AND firstName == 'John'") matches only if both conditions are fulfilled
//• [OR] filter("age == 26 OR firstName == 'John'") matches if any of the conditions are fulfilled
//• [NOT] filter("NOT firstName == 'John'") matches if the conditions is not fulfilled

//String operators
//• [BEGINSWITH] filter("firstName BEGINSWITH 'J'") matches if the firstName value starts with J
//• [CONTAINS] filter("firstName CONTAINS 'J'") matches if the firstName value contains anywhere J.
//• [ENDSWITH] filter("lastName ENDSWITH 'er'") matches if the lastName value ends with er
//• [LIKE] filter("lastName LIKE 'J*on'") matches if value starts with 'J', continues with any kind of sequence of symbols, and ends on 'on', e.g. Johnson, Johansson, etc. In the search pattern a ? matches one symbol of any kind and * matches zero or more symbols.

//Aggregate operators and key-paths (abbrev.)
//• [ANY] filter("ANY people.firstName == 'Frank'") matches if at least one of the objects in the people list has a property firstName equal to 'Frank'
//• [NONE] filter("NONE people.firstName == 'Frank'") matches if none of the objects in the people list has a property firstName equal to 'Frank'
//• [@count] filter("people.@count == 2") matches objects whose people list contains exactly two elements




//Sorting results
Example.of("Sorting") {
    let sortedPeople = realm.objects(Person.self) //모두 가져온다.
        .filter("firstName BEGINSWITH %@", "J")
        //firstName이 J로 시작하는 요소 필터링
        .sorted(byKeyPath: "firstName") //firstName으로 정렬
        //문자열 속성은 알파벳 순으로, 숫자 속성은 숫자, 시간은 날짜 순으로 정렬
        //기본적으로 오름차순으로 정렬
    
    let names = sortedPeople
        .map { $0.firstName } //firstName만 추출해 매핑
        .joined(separator: ", ") //연결
    print("Sorted people: \(names)")
    
    let sortedPeopleDesc = realm.objects(Person.self) //모두 가져온다.
        .filter("firstName BEGINSWITH %@", "J")
        //firstName이 J로 시작하는 요소 필터링
        .sorted(byKeyPath: "firstName", ascending: false) //오름차순 false
        //firstName으로 내림 차순 정렬
    
    let revNames = sortedPeopleDesc
        .map { $0.firstName } //firstName만 추출해 매핑
        .joined(separator: ", ") //연결
    print("Reverse-sorted People: \(revNames)")
    
    let sortedArticles = realm.objects(Article.self)
        .sorted(byKeyPath: "author.firstName")
        //첫 번째 매개변수를 키 패스로 지정해 줄 수도 있다(객체 링크의 속성을 참조).
        //자신의 속성 자체가 아닌, 속성에 연결된 속성으로 정렬
    print("Sorted articles by author: \n\(sortedArticles.map { "- \($0.author!.fullName): \($0.title!)" }.joined(separator: "\n"))")
    
    let sortedPeopleMultiple = realm.objects(Person.self) //모두 가져온다.
        .sorted(by: [ //여러 가지 keypath로 다중 정렬할 수 있다.
            SortDescriptor(keyPath: "firstName", ascending: true),
            //firstName 오름 차순으로 정렬
            SortDescriptor(keyPath: "born", ascending: false)
            //그 후, born을 내림차순으로 정렬 (첫 정렬이 일치하는 요소에 대한 정렬)
            ])
        //SortDescriptors은 정렬할 속성 명을 설정하고, 정렬방법을 지정하는 래퍼
    
    print(sortedPeopleMultiple.map { "\($0.firstName) @ \($0.born)" }.joined(separator: ", "))
}




//Live results
Example.of("Live Results") {
    let people = realm.objects(Person.self) //전체 요소 가져온다.
        .filter("key == 'key'") //key가 'key'인 요소 필터링
    print("Found \(people.count) people for key \"key\"")
    //default로 넣어 놓은 Data들 중에는 key가 'key'인 요소가 없다.
    
    let newPerson1 = Person()
    newPerson1.key = "key"
    
    try! realm.write { //key가 'key'인 요소를 추가한다.
        realm.add(newPerson1)
    }
    print("Found \(people.count) people for key \"key\"")
    //따로 추가하지 않았지만, Realm의 Results 집합은 항상 최신 결과를 반환한다.
    //따라서 결과를 다시 로드하거나 메모리 내 데이터를 수동으로 새로 고칠 필요가 없다.
    
    let newPerson2 = Person()
    newPerson2.key = "key"
    newPerson2.firstName = "Sher"
    print("Found \(people.count) people for key \"key\"")
    //newPerson2은 Realm에 추가하지 않았기 때문에 Results 집합에 포함되지 않는다.
    //또한, key가 고유값이 되어야 하기 때문에 중복되는 key를 추가할 수 없다.
    //추가를 시도할 시 런타임 에러가 난다.
    
    //Live Results는 매우 유용한 기능이며, Realm의 변경 알림 기능을 함께 사용하면,
    //언제 어떤 데이터가 변경되었는지 쉽게 알 수 있다.
}




//Writing objects
//Realm에 대한 모든 수정 사항은 write 트랜잭션 내에서 수행해야 한다.
//쓰기 트랜잭션을 수행하는 데 도움이 되는 두 가지 API가 있다.
//첫 번째는 클로저로, 클로저 내에서 추가한 변경 사항은 write 트랜잭션에서 수행된다.
//try! realm.write { }
//write(_)는 장치에 여유 공간이 없거나 파일이 손상된 경우 오류를 발생시킨다.

//두 번째 방법은 더 유연하지만 코드가 추가로 필요하다.
//beginWrite()를 사용하여 트랜잭션을 명시적으로 시작하고
//commitWrite()로 트랜잭션을 커밋한다.
//cancelWrite()를 사용해 모든 변경 사항을 롤백할 수도 있다.
//realm.beginWrite()
//realm.cancelWrite()
//try! realm.commitWrite()

//객체를 명시적으로 추가 및 제거하는 것만이 Realm의 수정은 아니다.
//객체가 지속되면, 객체 특성 값을 변경할 때 마다 디스크의 객체도 수정된다.
//이 객체는 write 트랜잭션 내에서 수행해야만 한다.




//Adding objects to Realm
//• Realm.add(_ object:update:) : 단일 객체와 아직 유지되지 않은 모든 링크 유지
//• Realm.add(_ objects:update:) : 객체 모음을 유지
//add 시에 같은 키를 가진 객체가 이미 Realm에 존재하면 오류가 발생한다.
//이미 존재하는 객체를 추가하는 경우에는 update라는 두 번째 매개 변수를 설정해야 한다.
//realm.add(newPerson, update: true) : newPerson 객체를 Realm에 추가하지만
//  동일한 기본 키가 있는 객체가 존재하는 경우에는 덮어쓴다.

//Cascading inserts
//계단식 삽입. persisted 객체는 non-persisted 객체를 가리킬 수 없다.
//따라서, Realm은 명시적으로 add(_)뿐 아니라, non-persisted 객체를 추가한다.
Example.of("Cascading Inserts") {
    let newAuthor = Person()
    newAuthor.firstName = "New"
    newAuthor.lastName = "Author"
    
    let newArticle = Article()
    newArticle.author = newAuthor //링크
    //이 순간에는 아직 write하지 않았기에 두 객체 모두 메모리에만 존재한다.
    
    try! realm.write {
        realm.add(newArticle)
        //NewArticle만 Realm에 추가했지만, newAthor를 참조하기 때문에
        //newAuthor도 Realm에 추가가 된다. Cascading inserts
    }
    
    let author = realm.objects(Person.self)
        .filter("firstName == 'New'")
        .first!
    
    print("Author \"\(author.fullName)\" persisted with article")
    //NewArticle만 Realm에 추가했지만, newAthor를 참조하기 때문에
    //newAuthor도 Realm에 추가가 된다. Cascading inserts
    //Realm이 데이터 무결성을 유지한다.
}

//Updating objects
//수정하는 방법도 유사하다. 속성이 변경되면, 나머지는 Realm이 처리한다.
Example.of("Updating") {
    let person = realm.objects(Person.self).first!
    print("\(person.fullName) initially - isVIP: \(person.isVIP), allowedPublication: \(person.allowedPublicationOn != nil ? "yes" : "no")")
    
    try! realm.write { //수정. update
        person.isVIP = true
        person.allowedPublicationOn = Date()
    }
    print("\(person.fullName) initially - isVIP: \(person.isVIP), allowedPublication: \(person.allowedPublicationOn != nil ? "yes" : "no")")
    //Realm의 Results는 최신의 결과를 유지하기 때문에 수동으로 다시 쿼리해 줄 필요 없다.
}




//Deleting objects
//삭제된 객체에 링크된 객체는 링크 속성이 nil로 된다.
//삭제된 객체가 List 속성에 연결되어 있었다면 List에서 제거된다.
Example.of("Deleting") {
    let people = realm.objects(Person.self) //전체 불러오기
    print("There are \(people.count) people before deletion: \(people.map { $0.firstName }.joined(separator: ", "))")
    
    try! realm.write {
        realm.delete(people[0]) //첫 객체 삭제
        realm.delete([people[1], people[5]]) //두 번째와 6번째 삭제
        realm.delete(realm.objects(Person.self)
            .filter("firstName BEGINSWITH 'J'")) //firstName이 J로 시작 필터링
        //delete로 하나 혹은 다중의 객체를 삭제할 수 있다.
    }
    
    print("There are \(people.count) people before deletion: \(people.map { $0.firstName }.joined(separator: ", "))")
    
    print("Empty before deleteAll? \(realm.isEmpty)") //비었는지 검사
    try! realm.write {
        realm.deleteAll() //모든 객체 삭제
        //새롭게 시작해야 할 때 유용
    }
    print("Empty after deleteAll? \(realm.isEmpty)")
}

