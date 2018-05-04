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

import RealmSwift
print("Ready to play!")

// Add your code below

//Opening a Realm
//Realm을 초기화하는 방법에는 2가지가 있다.
//첫 번째는 기본 Realm 파일을 초기화 하는 것이다.
//let realm = try! Realm()
//두 번째 방법으로는 매개변수를 이용해 특정 Realm의 구성 설정을 가져와 초기화한다.
// let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "TemporaryRealm"))
//여기선 메모리에 저장한다(디스크에 저장하는 것과 반대).

//Sharing a Realm instance, or making a new one?
//Realm은 일반 다른 DB와 다르게, 현재 앱에서 활성화된 모든 Realm의 정보를 유지한다.
//새 Realm을 만들려고 할 때마다 동일한 스레드의 다른 지점에서 이미 Realm을 사용하고 있다면,
//공유 인스턴스를 반환한다. 이를 통해 Realm은 몇 가지 런타임 최적화를 제공할 수 있다.
//• Realm()으로 생성하면, Realm 인스턴스를 만든 스레드와 관계없이 각 Realm 파일에 대해
//  동일한 공유 인스턴스가 반환된다. 객체 인스턴스와 Realm 인스턴스는 작성된 스레드로
//  제한되므로, 스레드 간에 공유할 수는 없다. Realm은 이미 스레드 단위로 Realm 인스턴스의
//  캐싱을 처리하고 필요에 따라 반환한다.
//• Realm(configuration: )을 사용할 때는 여러가지 조치를 한다.
//  ex. 다른 암호화 키로 동일한 파일을 열려고 하거나 파일이 없는 경우 오류 발생.

//코드의 여러 부분에 Realm 인스턴스를 공유하는 것은 비 효율적이다.
//인스턴스가 생성된 스레드에만 한정되어 있다. 복잡한 작업은 백 그라운드에서 수행할 수 있다.
//일반적으로 Realm 인스턴스를 만들려면 스레드 안전성을 유지하고, 작업중인 특정 스레드에 대해
//항상 Relam을 확보해야 한다.




//Working with configuration options
//몇 가지 Configuration options이 있다.
//• fileURL : 파일 기반 Realm을 만드는 데 사용된다.
//  ex. 데이터를 디스크에 유지하는 경우
//• inMemoryIdentifier : 메모리 내에 Realm을 만든다.
//  ex. 데이터를 디스크에 유지하지 않는 경우
//• syncConfiguration : 실시간 서버 데이터 동기화 활성화
//• encryptionKey : 기존 암호화된 파일을 새로 만들거나 열 때 사용하는 암호화 키
//• readOnly : 읽기 전용 모드
//• objectTypes : 지정된 Realm의 객체 목록. default
//• schemaVersion : 특정 DB 스키마 버전 설정
//• migrationBlock : 스키마 마이그레이션 위해 제공하는 클로저
//• deleteRealmIfMigrationNeeded : 이전 버전의 응용 프로그램으로 작성된 경우, 열기 전에
//  Realm 파일을 삭제한다. 기존 앱 데이터를 계속 사용하지 않으려는 경우, 클래스 디자인이
//  지속적으로 수정되는 경우 유용하다.
//• shouldCompactOnLaunch : 파일을 열기 전, Realm이 파일 압축을 시도해야 하는 지 여부
//  정의하는 클로저 제공




//Default configuration options
Example.of("New Configuration") {
    let newConfig = Realm.Configuration()
    //아무 설정 없이 생성 시 의미 있는 유일한 옵션은 현재 컨테이너의 Documents 폴더에 있는
    //default.realm 이라는 파일을 가리키는 fileURL이다.
    
    //단일 Realm로 작업하는 경우, 이 설정은 대부분은 경우 좋은 선택이 될 수 있다.
    print(newConfig)
}

Example.of("Default Configuration") {
    let defaultConfig = Realm.Configuration.defaultConfiguration
    //엑세스 할 때마다 새 구성을 작성하는 것을 피하기 위해, Realm.Configuration에
    //공유 정적 인스턴스가 있다. defaultConfiguration로 생성된 Realm은
    //아무 설정 없이 생성한 Realm과 동일하다. defaultConfiguration를 사용하면,
    //앱 코드 전체에서 엑세스 할 수 있다.
    //즉, let realm = try! Realm()로 생성한 것과 같다.
    
    print(defaultConfig)
    
    //처음 앱의 스키마 버전은 0이다. 다음 버전을 릴리즈한 이후 1로 버전을 업데이트 해야 한다면,
    //Realm 인스턴스를 만들 때마다 조정할 필요 없이 기본 설정을 바꿔 줄 수 있다.
//    var config = Realm.Configuration.defaultConfiguration
//    config.schemaVersion = 1
//    Realm.Configuration.defaultConfiguration = config
    //이후, let realm = try! Realm()를 호출할 때마다 스키마 버전은 1이 된다.
}




//In-memory Realms
//메모리에 Realm을 유지시킬 수도 있다. 메모리가 해제되면 사라지기 때문에, 주로 유지할 필요없는
//데이터의 성능 향상이나, 테스트를 위해 사용된다.
//inMemoryIdentifier는 파일 경로와 동일하다. 즉, Realm에 고유한 식별자를 제공하므로
//이 객체에 유지된 객체는 해당 특정 Realm에 포함된다.
Example.of("In-Memory Configuration") {
    let memoryConfig1 = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm1")
    print(memoryConfig1)
    
    let memoryConfig2 = Realm.Configuration(inMemoryIdentifier: "InMemoryRealm2")
    print(memoryConfig2)
    //memoryConfig1과 memoryConfig2는 메모리 내에서 관리되는, 동일한 객체 스키마
    //(Person, Article)를 가진다. 각각 개별 컨테이너에 대한 엑세스를 제공한다.
    
    let realm1 = try! Realm(configuration: memoryConfig1)
    let people1 = realm1.objects(Person.self)
    
    try! realm1.write {
        //in-memory라도, 추가/수정에는 write 트랜잭션을 사용해야 한다.
        realm1.add(Person()) //realm1에 유지된다.
    }
    
    print("People (1): \(people1.count)")
    
    let realm2 = try! Realm(configuration: memoryConfig2)
    let people2 = realm2.objects(Person.self)
    print("People (2): \(people2.count)")
    //식별자에 의해 고유하게 관리된다.
}




//Realms in a custom location
//쓰기 가능한 경로에 Realm 파일을 만들 수 있다.

//Documents folder
//기본 설정은 앱의 Documents 폴더의 default.realm 파일을 사용한다.
Example.of("Documents Folder Configuration") {
    let documentsUrl = try! FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        //Documents 폴더의 URL 반환
        .appendingPathComponent("myRealm.realm") //파일 이름 추가
        //default 대신 Realm 파일 위치와 명을 지정해 줄 수 있다.
    
    let documentsConfig = Realm.Configuration(fileURL: documentsUrl)
    //fileURL로 지정된 경로(URL)의 Realm 파일을 열 수 있다.
    print("Documents-folder Realm in: \(documentsConfig.fileURL!)")
    
    //Realm(configuration:)을 호출하면, Realm은 지정된 fileURL에 파일이 있는지
    //확인한다. 없으면 빈 Realm 파일이 자동으로 만들어져 열린다.
    
    //Documents 폴더에 저장하면, 파일은 사용자의 iCloud에 자동 백업되며, iTunes를
    //사용해, 쉽게 백업하고 접근할 수 있다. 그러나 Apple은 기본적으로 응용 프로그램의 파일을
    //Documents가 아닌 Library 폴더에 저장하는 것을 권장한다.
}

//Library folder
//iCloud에 자동 백업 하지 않으려면 Library 폴더를 사용해야 한다.
Example.of("Library Folder Configuration") {
    let libraryUrl = try! FileManager.default
        .url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
         //Library 폴더의 URL 반환
        .appendingPathComponent("myRealm.realm") //파일 이름 추가
        //default 대신 Realm 파일 위치와 명을 지정해 줄 수 있다.
    
    let libraryConfig = Realm.Configuration(fileURL: libraryUrl)
    //fileURL로 지정된 경로(URL)의 Realm 파일을 열 수 있다.
    print("Realm in Library folder: \(libraryConfig.fileURL!)")
}

//App Bundle folder
//Realm 파일이 앱과 함께 번들로 포함되어 있고, 이를 열거나 저장된 객체 중 일부를 가져오는 경우,
//Bundle을 사용하여 앱의 resources 폴더에 접근할 수 있다. Bundle은 읽기 전용 클래스임을
//유의해야 한다. 새 파일을 추가하거나 기존 파일을 수정할 수는 없다.
//let bundledURL = Bundle.main
//    .url(forResource: "bundledRealm", withExtension: "realm")
//let bundleConfig = Realm.Configuration(fileURL: bundledURL)
//PlayGround에서는 번들이 없으므로 사용할 수 없다.

//Shared container
//Realm 파일을 저장하는 또 다른 일반적인 위치는 iOS 앱과
//확장 프로그램 중 하나 사이에 공유되는 폴더이다.
//let sharedURL = FileManager.default
//    .containerURL(forSecurityApplicationGroupIdentifier:
//        "group.com.razeware.app")!
//    .appendingPathComponent("Library/shared.realm")
//let sharedConfig = Realm.Configuration(fileURL: sharedURL)
//PlayGround에서는 사용할 수 없다.
//containerURL(forSecurityApplicationGroupIdentifier:)를 사용해 공유 로컬 URL을
//가져올 수 있다. 공유 URL은 확장 프로그램과 앱이 지정된 그룹 식별자를 통해 접근할 수 있다.
//이 URL로 configuration과 Realm을 만들면, 두 대상에서 모두 객체를 읽고 쓸 수 있다.




//Encrypted realms
//Realm은 암호화된 데이터를 매우 간단하게 작성하고 작업할 수 있다.
//암호화와 복호화를 위해 원하는 키를 사용하여 configuration의 encryptionKey 속성을
//설정하면 나머지는 자동으로 수행된다. 암호화된 파일을 처음 열면 Realm에서 디스크에 암호화된
//파일을 만들고 지정된 키로 암호화한다. 나중에 동일한 암호화 키로 동일한 configuration을
//사용해야 하는 데이터를 읽거나 쓴다. Realm은 64바이트 키를 사용해 데이터를 암호화한다.
//잘못된 키가 있는 Realm 파일을 열려고 하면, 오류가 발생한다.
//var cryptoConfig = Realm.Configuration()
//do {
//    cryptoConfig.encryptionKey = Data(...)
//    let cryptoRealm = try Realm(configuration: cryptoConfig)
//    print(cryptoRealm)
//} catch let error as NSError {
//    print("Opening file failed: \(error.localizedDescription)")
//}
//PlayGround에서는 사용할 수 없다.




//Read-only Realms
//읽기 전용 Realm의 특징은 다음과 같다.
//• : write 트랜잭션을 시작하자 마자 예외가 발생한다.
//• : 특정 configuration에 대한 변경 알림을 트리거 하지 않는다는 것을 알기에,
//  Realm이 성능을 최적화한다.
Example.of("Read-only Realm") {
    let rwUrl = try! FileManager.default
        .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        .appendingPathComponent("newFile.realm")
        //default로 Realm 생성
    
    let rwConfig = Realm.Configuration(fileURL: rwUrl)
    //default로 생성 했으므로 기본적으로 읽기, 쓰기 모두 가능하다.
    
    autoreleasepool {
        //코드 완료 후, Realm 인스턴스에 핸들러가 있는지 확인하려면
        //autoreleasepool가 필요하다.
        //autoreleasepool로 release 해야 할 객체들을 모아두었다가 적절한 시점에 동시
        //해제할 수 있다.
        //http://blog.naver.com/PostView.nhn?blogId=itperson&logNo=220819529932&parentCategoryNo=&categoryNo=&viewDate=&isShowPopularPosts=false&from=postView
        let rwRealm = try! Realm(configuration: rwConfig)
        try! rwRealm.write {
            rwRealm.add(Person())
        }
        
        print("Regular Realm, is Read Only?: \(rwRealm.configuration.readOnly)")
        //readOnly를 통해 읽기 전용 여부를 알 수 있다.
        //기본 구성을 생성했기 때문에 read only가 아니다.
        print("Saved objects: \(rwRealm.objects(Person.self).count)\n")
    }
    
    autoreleasepool {
        let roConfig = Realm.Configuration(fileURL: rwUrl, readOnly: true)
        //읽기 전용
        //write 트랜잭션을 실행하려 하면 오류가 난다.
        
        let roRealm = try! Realm(configuration: roConfig)
        print("Read-Only Realm, is Read Only?: \(roRealm.configuration.readOnly)")
        print("Read objects: \(roRealm.objects(Person.self).count)")
    }
}




//Object schema
//기본적으로 Realm은 앱의 Realm 객체를 검사하고 기본적으로 이런 검사된 객체를 기반으로
//전체 DB 스키마를 정의한다.
Example.of("Object Schema - Entire Realm") {
    let realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "Realm"))
    
    print(realm.schema.objectSchema)
    //Realm의 전체 스키마를 출력. 모든 객체 유형에 대한 ObjectSchemas 배열
    //Realm.schema.objectSchema에는 해당 메타 정보와 함께 유지되는 모든 데이터 등록
    //정보의 목록을 포함해 Realm에 저장된 모든 객체에 대한 설명이 있다.
}

Example.of("Object Schema - Specific Object") {
    let config = Realm.Configuration(inMemoryIdentifier: "Realm2", objectTypes: [Person.self])
    //Person과 Article 객체가 있지만, 일부 Realm에서 Person 객체만 유지하려 한다 하면,
    //Configuration에 objectTypes을 추가하고 해당 특정 Realm을 지속하는 데 관심 있는
    //모든 객체를 나열하여 수행할 수 있다.
    
    let realm = try! Realm(configuration: config)
    print(realm.schema.objectSchema)
    //objectSchema에서 Article 객체를 건너 뛰고 Person 객체 메타 정보만 포함된다.
}
