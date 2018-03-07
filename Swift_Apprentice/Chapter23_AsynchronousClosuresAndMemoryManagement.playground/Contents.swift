//: Chapter 23: Asynchronous Closures and Memory Management

//Reference cycles for classes

import Foundation
import PlaygroundSupport

class Tutorial {
    let title: String
    unowned let author: Author //unowned는 weak과 유사하지만 항상 값이 있을 것으로 예상될 때 사용된다.
    weak var editor: Editor? //weak 참조로 하면 특정 개체의 참조 카운트를 증가시키지 않는다. 따라서 메모리 누수를 막을 수 있다.
    //항상 에디터가 할당되는 것은 아니기 때문에 weak 참조로 모델링 하는 것이 좋다.
    //weak 참조는 런타임 중에 nil로 될 수 있기 때문에 상수로 정의할 수 없다. 반드시 weak var
    
    lazy var createDescription: () -> String = { //lazy로 선언하면 사용되기 전에는 할당되지 않는다.
        [unowned self] in //캡처 리스트 //Unowned self : self는 값이 있음을 가정
        return "\(self.title) by \(self.author.name)" //클로저는 값을 캡쳐하면서 참조를 만든다.
        //https://outofbedlam.github.io/swift/2016/01/31/Swift-ARC-Closure-weakself/
    }
    
    init(title: String, author: Author) {
        self.title = title
        self.author = author
    }
    
    deinit {
        print("Goodbye Author \(title)!")
    }
}

class Editor {
    let name: String
    var tutorials: [Tutorial] = []
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("Goodbye Author \(name)!")
    }
}

class Author {
    let name: String
    var tutorials: [Tutorial] = []
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("Goodbye Author \(name)!")
    }
}

//do { //do로 코드를 감싸면 do {}안의 인스턴스들은 이 범위륿 벗어나면 할당이 해제된다.
//    let tutorial: Tutorial = Tutorial(title: "Memory management")
//    let editor: Editor = Editor(name: "Ray")
//}
//
//do {
//    let tutorial: Tutorial = Tutorial(title: "Memory management")
//    let editor: Editor = Editor(name: "Ray")
//
//    tutorial.editor = editor
//    editor.tutorials.append(tutorial)
//} //tutorial과 editor가 서로 참조하기 때문에 일반적으로는 메모리가 해제되지 않는다.(weak)

//Unowned references
do {
    let author = Author(name: "Cosmin")
    let tutorial = Tutorial(title: "Memory management", author: author)
    print(tutorial.createDescription()) ////클로저는 값을 캡쳐하면서 참조를 만든다. //tutorial과 클로저 사이에 참조가 생기기 때문에 메모리가 해제되지 않는다.
    
    author.tutorials.append(tutorial) //author와 tutorial이 서로 참조하기 때문에 일반적으로는 메모리가 해제되지 않는다.(unowned)
}

//Capture lists
//캡처 리스트는 클로저에 의해 캡처되는 변수들의 배열
var counter = 0
var closure = { print(counter) }
counter = 1
closure() //1 //클로저는 값을 캡처한므로 업데이트 된 값이 출력된다.

counter = 0
closure = { [counter] in print(counter) } //원래의 값을 출력하고 싶다면 싶다면 캡처 리스트를 만들어야 한다.
counter = 1
closure()

//클로저에 의해 self가 캡쳐될때 strong대신에 unowned 레퍼런스로 캡쳐된다. 따라서 nil을 설정하면 정상적으로 인스턴스가 소멸된다.
//https://outofbedlam.github.io/swift/2016/01/31/Swift-ARC-Closure-weakself/

//Handling asynchronous closures
//멀티 스레드. 인터페이스 변화는 항상 주 스레드에서 작업해야 한다. 따라서 네트워크는 보통 백그라운드 스레드로 하여 인터페이스 변경이 차단되지 않도록 한다.
//Grand Central Dispatch, GCD를 사용하여 관리

//GCD
func log(message: String) {
    let thread = Thread.current.isMainThread ? "Main" : "Background" //삼항 연산자
    print("\(thread) thread: \(message)")
}

func addNumbers(upTo range: Int) -> Int {
    log(message: "Adding numbers...")
    
    return (1...range).reduce(0, +)
}

let queue = DispatchQueue(label: "queue") //큐 생성

func execute<Result>(backgroundWork: @escaping () -> Result, mainWork: @escaping (Result) -> ()) {
    //클로저는 기본적으로 non escape. 여기선 클로저가 이 함수 범위를 벗어나서 작동하므로 escaping키워드를 써줘야 한다.
    queue.async { //비동기로 실행
        let result = backgroundWork()
        
        DispatchQueue.main.async { //메인 큐에서 비동기로 실행 //backgroundWork의 결과를 사용한다.
            mainWork(result)
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true //플레이그라운드에서 비동기 실행하는 모드. //기본적으로 플레이그라운드에서 비동기 실행 불가
execute(backgroundWork: { addNumbers(upTo: 100) }, mainWork: { log(message: "The sum is \($0)") })

//Weak self
extension Editor {
    func feedback(for tutorial: Tutorial) -> String {
        let tutorialStatus: String
        
        if arc4random_uniform(10) % 2 == 0 { //난수 생성
            tutorialStatus = "published"
        } else {
            tutorialStatus = "rejected"
        }
        
        return "Tutorial \(tutorialStatus) by \(self.name)"
    }
    
    func editTutorial(_ tutorial: Tutorial) {
        queue.async() { //비동기 작업 중 어떤 시점에서는 self가 nil이 될 수 있으므로, unowned로는 캡쳐할 수 없을 때가 있다.
//            [unowned self] in //unowned으로 선언했으므로 self가 존재해야 한다.
//            let feedback = self.feedback(for: tutorial) //하지만 비동기로 실행되기 때문에 editTutorial함수가 완료되기 전에, editor가 범위를 벗어나게 되면 self의 참조값이 없어지므로 충돌이 일어날 수 있다.
//            DispatchQueue.main.async {
//                print(feedback)
//            } //위의 execute 함수와 비교. execute는 메서드가 아닌 함수이므로 self를 신경 쓸 필요가 없었다.
            
            [weak self] in //The strong weak pattern. //weak self로 하여 self가 nil이 될 수도 있다.
            guard let strongSelf = self else { //editor가 범위를 벗어나도 클로저가 실행되게 하려면 self에 대한 strong 참조를 만들어야 한다.
                print("I no longer exist so no feedback for you!")
                return
            }
            
            DispatchQueue.main.async {
                print(strongSelf.feedback(for: tutorial))
            }
        }
    }
}

do {
    let author = Author(name: "Cosmin")
    let tutorial: Tutorial = Tutorial(title: "Memory management", author: author)
    let editor: Editor = Editor(name: "Ray")
    
    author.tutorials.append(tutorial)
    tutorial.editor = editor
    editor.tutorials.append(tutorial)
    editor.editTutorial(tutorial)
}





