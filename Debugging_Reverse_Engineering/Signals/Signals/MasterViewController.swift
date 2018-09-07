/**
 * MasterViewController.swift
 *
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class MasterViewController: UITableViewController {
  override var description: String { //해당 ViewController를 출력할 때 보여지는 String
    return "Yay! debugging " + super.description
  }
  
  override var debugDescription: String { //NSObject에는 debugDescription이라는 디버깅에 사용되는 추가 메서드 description이 있다.
    //LLDB에서 객체를 출력할 때(po) debugDescription이 호출된다.
    //NSObject 클래스 또는 하위 클래스 에만 영향을 미친다.
    return "debugDescription: " + super.debugDescription
  }

  // MARK: - Properties
  var detailViewController: DetailViewController? = nil

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    print("\(self)") //현재 self 를 출력한다(description이 있으면 description String이 출력된다).

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handleNotification(notification:)),
                                           name: NSNotification.Name.signalHandlerCountUpdated,
                                           object: nil)

    guard let navigationController = splitViewController?.viewControllers.last as? UINavigationController,
      let detailViewController = navigationController.topViewController as? DetailViewController else {
        return
    }

    self.detailViewController = detailViewController
  }

  override func viewWillAppear(_ animated: Bool) {
    self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
    super.viewWillAppear(animated)

    if let bottomInset = (parent as? MasterContainerViewController)?.suggestedBottomContentInset {
      var contentInset = tableView.contentInset
      contentInset.bottom = bottomInset
      tableView.contentInset = contentInset
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "showDetail",
      let indexPath = self.tableView.indexPathForSelectedRow,
      let navigationController = segue.destination as? UINavigationController,
      let controller = navigationController.topViewController as? DetailViewController else {
        return
    }

    let signal = UnixSignalHandler.shared().signals[indexPath.row]
    controller.signal = signal
  }
}

// MARK: - UITableViewDataSource
extension MasterViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    }

    return UnixSignalHandler.shared().signals.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard indexPath.section > 0 else {
      return tableView.dequeueReusableCell(withIdentifier: "Toggle", for: indexPath)
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SignalsTableViewCell
    let signal = UnixSignalHandler.shared().signals[indexPath.row]
    cell.setupCellWithSignal(signal: signal)
    return cell
  }
}

// MARK: - IBActions
extension MasterViewController {

  @IBAction func breakpointButtonItemTapped(_ sender: AnyObject) {
    raise(SIGSTOP)
  }

  @IBAction func breakpointsEnableToggleTapped(_ sender: UISwitch) {
    let shouldEnable = sender.isOn

    if !shouldEnable {
      let controller = UIAlertController(title: "Signals Disabled",
                                         message: "All catchable Signals handlers will be ignored. Certain signals, like SIGSTOP, can not be caught",
                                         preferredStyle: .alert)
      controller.addAction(UIAlertAction(title: "OK", style: .default))
      present(controller, animated: true)
    }

    UnixSignalHandler.shared().shouldEnableSignalHandling = shouldEnable
  }
}

// MARK: - Notifications
extension MasterViewController {

  @objc func handleNotification(notification: Notification) {
    tableView.reloadSections(IndexSet(integer: 1), with: .fade)
  }
}
//**************************************** Ch4. Stopping in Code ****************************************
//Xcode의 사이드 패널을 클릭하면 GUI를 사용해 breakpoint를 쉽게 만들 수 있지만,
//LLDB 콘솔을 사용하면 중단점을 훨씬 효과적으로 제어할 수 있다.




//Signals
//해당 프로그램은 유닉스 signal을 모니터하면서 signal을 받으면 표시한다.
//유닉스 신호는 프로세스 간 통신의 기본 형식이다.
//ex. SIGSTOP 을 사용하여 프로세스의 상태를 저장하고 실행을 일시 정지할 수 있다.
//ex. SIGCONT 는 실행을 재개하기 위해 프로그램에 보낸다.
//디버거에서는 이 두 신호를 모두 사용하여 프로그램 실행을 일시 중지하고 계속할 수 있다.
//제어 프로세스(LLDB)가 유닉스 신호를 제어된 프로세스로 전달될 때마다 표시할 수 있다.
//UISwitch 토클은 C 함수 sigprocmask를 호출하여 신호 핸들러를 활성/비활성 한다.
//Timeout bar 버튼은 SIGSTOP 신호를 발생시켜 프로그램을 정지 시킨다.

//시뮬레이터를 빌드한 상태에서, 디버거를 일시정지한다(console 창 좌측 일시정지 버튼)
//그리고 continue로 resume하면, 시뮬레이터의 UITableView에 새로운 셀이 추가된다.
//SIGSTOP Unix 신호를 모니터링하고, 이가 발생할 때 마다 데이터 모델에 행을 추가하기 때문이다.
//프로세스가 중지되면, 프로그램이 일종의 정지 상태이기 때문에 새로운 신호는 즉시 처리되지 않는다.




//Xcode breakpoints
//Xcode의 Symbolic Breakpoint는 애플리케이션 내의 특정 심볼에 breakpoint 를 설정한다.
//ex. 심볼의 예시는 - [NSObject init]. 이는 NSObject의 init 메서드를 참조한다.
//Xcode의 Symbolic Breakpoint는 breakpoint를 설정해 두면, 다음에 프로그램을 재시작해도 저장되어 있어 재 설정할 필요가 없다.

//생성된 모든 NSObject 보기 p.51
//프로그램을 종료 하고, Breakpoint Navigator 에서 좌측 하단의 + 버튼을 눌러 Symbolic Breakpoint... 를 선택한다.
//Symbol : -[NSObject init]
//Action : Debugger Command
//         po [$arg1 class]
//Automatically continue after evaluating actions 에 체크한다.
//빌드하고 실행하면, Xcode는 콘솔에 Signals 프로그램을 실행하는 동안 초기화되는 클래스의 모든 이름을 출력한다.
//breakpoint에서 설정한 명령(po)이 LLDB에서 실행되고, Automatically continue를 체크 했기에 다음 breakpoint로 넘어간다.
//$arg1는 $rdi 와 같다고 생각하면 된다. init가 호출될 때 클래스의 인스턴스이다.
//Symbolic Breakpoint 외에도 Xcode에는 여러 유형의 breakpoint가 있다.
//그 중 하나인 Exception Breakpoint는 프로그램에 문제가 발생하여 crash 될 때 사용할 수 있다.
//또 Swift Error Breakpoint가 있다. Swift는 swift_willThrow 메서드에서 breakpoint을 생성하여 오류를 throw 한다.
//오류가 발생할 수 있는 API로 작업하는 경우 유용하다.




//LLDB breakpoint syntax
//LLDB 콘솔에서도 breakpoint를 생성할 수 있다. 먼저 정확한 부분에 breakpoint를 만들기 위해서는 찾고자 하는 것을 쿼리해야 한다.
//image 명령은 breakpoint 설정에 필요한 필수적인 세부 사항을 관찰하는데 도움이 된다.
//breakpoint 설정점을 찾기 위한 두 가지 구성이 있다. 첫 번째는
//(lldb) image lookup -n "-[UIViewController viewDidLoad]"
//-[UIViewController viewDidLoad] 에 대한 함수의 구현 주소(이 메서드의 프레임워크 이진 주소)를 출력한다.
//(lldb) image lookup -rn test
//"test"라는 단어에 대해 대/소 문자를 구분하는 정규식을 조회한다.
//소문자 "test"가 현재 실행 파일에 로드된 모듈(ex. UIKit, Foundation, Core Data 등)에 있는 함수에 포함될 경우 출력한다.
//-n 인수는 정확히 일치하는 항목(공백 포함된 경우에는 ""로 묶어야 함), -rn 인수는 이를 사용해 정규식 검색을 수행한다.
//-n only 명령은 Swift를 다룰 때 breakpoint와 일치하는 정확한 매개 변수를 알아내는 데 도움이 된다.
//-rn 인수로 정확히 검색할 수 있기 때문에 주로 사용된다.




//Objective-C properties
//Objective-C 와 Swift는 모두 컴파일러에서 생성될 때 특정 속성 서명을 가지므로 코드를 찾을 때 쿼리 방법이 달라진다. p.53

//@interface TestClass : NSObject
//@property (nonatomic, strong) NSString *name;
//@end
//위와 같은 Objective-C 코드의 경우, 컴파일러는 속성명의 setter, getter를 생성한다.
//따라서 getter의 경우 -[TestClass name], setter의 경우 -[TestClass setName:] 이다.

//빌드 후 디버거를 일시정지 한 후, LLDB에 다음을 입력해 메서드가 존재하는 지 확인한다.
//(lldb) image lookup -n "-[TestClass name]"

//1 match found in /Users/derekselander/Library/Developer/Xcode/
//DerivedData/Signals-atqcdyprrotlrvdanihoufkwzyqh/Build/Products/Debug-
//iphonesimulator/Signals.app/Signals:
//Address: Signals[0x0000000100001d60] (Signals.__TEXT.__text + 0)
//Summary: Signals`-[TestClass name] at TestClass.h:28

//출력된 정보는 위와 같은데, 여기서 몇 가지 정보를 알 수 있다. 이 메서드(-[TestClass name], TestClass의 name 속성 getter)는
//Signals 실행파일의 __TEXT 세그먼트의 __text 세션에 메모리 주소 0x0000000100001d60 로 있으며
//TestClass.h의 28 행에 선언되어 있음을 알 수 있다.
//setter에 대해서는 (lldb) image lookup -n "-[TestClass setName:]" 로 정보를 얻을 수 있다.




//Objective-C properties and dot notation
//Objective-C 의 dot notation은 속성에서 축약형 getter 또는 setter를 사용할 수 있다.

//TestClass *a = [[TestClass alloc] init];
//// Both equivalent for setters
//[a setName:@"hello, world"];
//a.name = @"hello, world";
//// Both equivalent for getters
//NSString *b;
//b = [a name]; // b = @"hello, world"
//b = a.name;   // b = @"hello, world"

//위의 예제에서 setter 인 -[TestClass setName:] 메서드는 dot notation에서도 호출된다(즉, 총 2번 호출된다).
//getter 인 -[TestClass name] 도 마찬가지다.




//Swift properties
//Swift에서는 위의 Objective-C와 매우 다르다.

//class SwiftTestClass: NSObject {
//  var name: String!
//}

//디버깅 창에서 Command + K를 입력하면 콘솔을 지울 수 있다. 다음을 입력한다.
//(lldb) image lookup -rn Signals.SwiftTestClass.name.setter

//1 match found in /Users/derekselander/Library/Developer/Xcode/
//DerivedData/Signals-atqcdyprrotlrvdanihoufkwzyqh/Build/Products/Debug-
//iphonesimulator/Signals.app/Signals:
//Address: Signals[0x000000010000cc70] (Signals.__TEXT.__text + 44816)
//Summary: Signals`Signals.SwiftTestClass.name.setter :
//Swift.ImplicitlyUnwrappedOptional<Swift.String> at SwiftTestClass.swift:28

//여기서도 몇 가지 정보를 알 수 있다. 가장 큰 차이점은 함수의 이름이 Signals.SwiftTestClass.name.setter 로 매우 길다.
//breakpoint를 설정할 때 이 메서드명을 모두 입력해 줘야 한다.
//(lldb) b Signals.SwiftTestClass.name.setter :Swift.ImplicitlyUnwrappedOptional<Swift.String>
//정규 표현식을 사용하는 것이 이 것을 일일이 입력하는 것보다 훨씬 낫다.
//또한, setter와 getter를 속성 뒤에 붙여서 구분한다(두 메서드 모두 선언 행은 같은 행으로 출력된다).
//(lldb) image lookup -rn Signals.SwiftTestClass.name
//위와 같이 사용하면 setter와 getter 모두 찾는다. 정규 표현식에서 dot(.)은 wild card로 사용된다.
//Swift 속성에 대한 함수의 이름에는 이와 같은 패턴이 있다.
//ModuleName.Classname.PropertyName.(getter | setter)
//이렇게 메서드를 덤프해 패턴을 찾고 검색 범위를 좁히는 것은 breakpoint를 정확히 설정하기 위한 좋은 방법이다.




//Finally... creating breakpoints
//실행 후, 디버깅을 일시 중단하고 진행한다.
//breakpoint를 만드는 가장 기본적인 방법은 b 와 breakpoint를 지정할 메서드나 속성의 이름을 입력하는 것이다.
//Objective-C 에서는 이름이 짧고 입력하기 쉽지만, Swift에서는 다소 길어져 입력하기 까다로울 수 있다.
//UIKit은 주로 Objective-C 이므로 Objective-C로 breakpoint를 만들 수 있다.
//(lldb) b -[UIViewController viewDidLoad]
//유효한 breakpoint가 생성되면 콘솔에서 해당 breakpoint에 대한 정보를 출력한다.
//일시 정지를 해제하고 다시 시작하면, SIGSTOP 신호가 표시되며 멈춘다.
//breakpoint를 생성하는 b 명령에도 많은 인자 옵션들이 있다.




//Regex breakpoints and scope
//regular expression breakpoint 은 rbreak로 쓸 수 있으며, 이는 breakpoint set -r %1의 약어이다.
//정규 표현식 breakpoint는 정규 표현식을 사용하여 원하는 곳마다 break point를 생성할 수 있다.

//(lldb) b Breakpoints.SwiftTestClass.name.setter : Swift.ImplicitlyUnwrappedOptional<Swift.String> 이 표현을
//(lldb) rb SwiftTestClass.name.setter 이렇게 줄여 줄 수 있다. 이렇게 하면, SwiftTestClass 에서 name의 setter 속성에 breakpoint가 만들어 진다.
//(lldb) rb name\.setter 로 더 간단하게 줄일 수 있다. 이는 name.setter 구문을 포함하는 모든 곳에 breakpoint가 생성된다.
//하지만, 이는 프로젝트 내의 다른 클래스에 name이라는 속성이 있으면, 그곳에도 breakpoint가 생성된다.

//(lldb) rb '\-\[UIViewController\ ' UIViewController의 모든 Objective-C 인스턴스 메서드에 breakpoint를 생성한다.
//\ 는 리터럴 문자가 정규 표현 식 검색에 있음을 나타내기 위한 이스케이프 문자이다.
//결과적으로 이 쿼리는 -[UIViewController (공백 한 칸 있음) 을 포함하는 모든 메서드에 breakpoint를 생성하게 된다.
//Objective-C 에서 카테고리는 (-|+) [ClassName(categoryName) method] 이런 식으로 추가한다.
//(lldb) breakpoint delete 를 입력하면 breakpoint를 삭제할 수 있다(breakpoint 대신 b 입력할 수 없다).
//(lldb) rb '\-\[UIViewController(\(\w+\))?\ ' 이것은 optional 괄호에 하나 이상의 알파벳이나 숫자를 나타낸다.?
//rb 를 사용하면, 단일 표현식을 사용하여 다양한 breakpoint를 캡쳐 할 수 있다.
//-f 옵션을 사용해, breakpoint의 범위를 특정 파일로 제한할 수 있다.
//(lldb) rb . -f DetailViewController.swift 이 기능은 DetailViewController.swift 를 디버깅할 때 유용하다.
//이 파일의 모든 속성의 property getters/setters, blocks/closures, extensions/categories, functions/methods 에 breakpoint를 설정한다.
//(lldb) rb . 이것은 이 프로젝트의 모든 것에  breakpoint를 추가한다.
//검색 범위를 제한하는 다른 방법은 -s 옵션을 사용해, 단일 라이브러리를 제한할 수 있다.
//(lldb) rb . -s Commons 이렇게 하면 Commons 라이브러리의 모든 것에 breakpoint가 생성된다.
//(lldb) rb . -s UIKit 이렇게 하면 UIKit 라이브러리의 모든 것에 breakpoint를 생성한다.

//-o로 one-shot b breakpoint를 설정할 수 있다. one-shot breakpoint는 한번만 실행된다. 즉 breakpoint에 도달하면, 해당 breakpoint를 삭제한다.
//(lldb) rb . -s UIKit -o




//Other cool breakpoint options
//-L 옵션을 사용하면 소스 언어로 필터링 할 수 있다.
//(lldb) breakpoint set -L swift -r . -s Commons 이는 Commons 모듈에서 Swift 코드만 수행한다.
//-p는 표현식, -A 옵션을 추가하면, 프로젝트의 모든 소스 파일을 검색한다.

//(lldb) breakpoint set -A -p "if let"
//이는 source regex breakpoints으로, if let 이 포함된 모든 소스 코드 위치에 breakpoint를 생성한다.
//필터링이 필요한 경우에는 -f 옵션을 사용할 수 있다.

//(lldb) breakpoint set -p "if let" -f MasterViewController.swift -f DetailViewController.swift
//이렇게 사용하면, MasterViewController.swift 와 DetailViewController.swift 에서만 해당 파일 내에서만 검색한다(-A 옵션이 없다).

//특정 모듈을 기준으로 필터링 할 수도 있다.
//(lldb) breakpoint set -p "if let" -s Signals -A
//Signals 모듈의(-s) 모든 소스 파일에서(-A) if let이 포함된 (-p) 부분에 breakpoint를 추가한다.

//-c 옵션으로 breakpoint 생성 시에 조건을 추가해 줄 수 있다. 직접 구현한 코드에서 해당 메서드가 호출된 경우를 찾고 싶은 경우를 생각해 보자.
//먼저 실행 파일의 코드가 메모리에 상주하는 범위의 상한선과 하한선을 알아야 한다. 일반적으로 코드는 __TEXT 세그먼트의 __text 섹션에 있다(Mach-O).
//__TEXT 세그먼트를 모든 실행 파일과 프레임워크에 있는 readable 하고 executable한 코드 그룹으로 생각하면 된다.
//LLDB를 사용해, Mach-O 세그먼트 및 섹션의 내용을 확인할 수 있다.
//(lldb) image dump sections Signals 이를 입력하면, 해당 프로젝트(signals)의 섹션을 출력한다. p.61
//콘솔에 출력된 값에서 Section Name이 Signals.__TEXT 으로 된 container의 Load Address가 각 하한선과 상한선이다.
//(lldb) breakpoint set -n "-[UIView setTintColor:]" -c "*(uintptr_t*)$rsp <= 0x000000010a474000 && *(uintptr_t*)$rsp >= 0x000000010a462000"
//-[UIView setTintColor:] 라는 메서드가 실행 파일 내에 구현된 코드(메모리 범위)에서 호출된 경우만 찾는다.
//하지만 이 경우, 헤드가 새로운 포인터를 가리키는 경우가 있기 때문에 LLDB가 헤더를 처음으로 옮겨줘야 한다.
//(lldb) settings set target.skip-prologue false 이를 입력해 수행할 수 있다.




//Modifying and removing breakpoints
//특정 breakpoint를 수정하거나 삭제해야 하는 경우가 있다. 먼저 breakpoint를 생성할 때, -N dhqtusdmfh breakpointdㅔ 이름을 설정해 줄 수 있다.
//(lldb) b main 그러면, Breakpoint 1: 70 locations. 메시지를 볼 수 있다. 이는 여러 모듈에서 "main" 으로 매칭되는 함수 70개에 breakpoint를 추가한다.
//세션에서 만든 첫 번째 breakpoint 이므로 id는 1이다. 이 breakpoint의 세부 사항을 보려면
//(lldb) breakpoint list 1 를 입력한다. 출력을 보면 main이라는 단어가 포함되었다는 걸 알 수 있다.
//(lldb) breakpoint list 1 -b 이렇게 입력하면, 간단하게 breakpont의 내용을 표시한다.
//(lldb) breakpoint list 해당 LLDB 세션의 모든 breakpoint를 조회하려면 이와 같이 한다.
//(lldb) breakpoint list 1 3 나 (lldb) breakpoint list 1-3 를 사용해, 범위를 지정해 줄 수도 있다.

//(lldb) breakpoint delete 1 삭제는 해당 id를 사용해 breakpoint를 삭제해 줄 수 있다.
//(lldb) breakpoint delete 1.1 를 사용해, 해당 id list의 위치에 해당하는 breakpoint만을 삭제할 수 있다.

//https://docs.python.org/2/library/re.html




//**************************************** Ch5. Expression ****************************************
//LLDB로 임의의 코드를 실행할 수 있다. 또한 Objecrive-C 런타임을 사용하면 프로그램을 이해하는 데 도움이 되는 코드를 즉시 선언하고 삽입할 수 있다.
//expression 명령으로 디버거에서 임의 코드를 실행한다.




//Formatting p & po
//po 는 Swift & Objective-C 코드에서 관심 항목을 출력하는 데 사용된다(객체의 인스턴스 변수, 로컬 reference, 레지스터 등).
//po는 expression -O -- 의 약어 표현이다. -O 는 객체의 설명을 인쇄하는 데 사용한다.
//p 는 -O 옵션이 생략된 표현이며, 따라서 expression -- 을 표현한 것이 된다. p가 출력할 형식은 LLDB 유형 시스템에 따라 다르다.
//LLDB의 형식 값은 출력을 결정하는 데 도움이 되며, 사용자가 정의할 수 있다.

//(lldb) po self 를 입력하면, 해당 self를 print(self) 한 것과 같은 출력이 나온다(description).
//NSObject에는 debugDescription이라는 디버깅에 사용되는 추가 메서드 description이 있다.
//LLDB에서 객체를 출력할 때(po) debugDescription이 호출된다.
//NSObject 클래스 또는 하위 클래스 에만 영향을 미친다.
//debugDescription를 대체하는 모든 Objective-C  클래스를 알고 싶다면 다음과 같이 쿼리하면 된다.
//(lldb) image lookup -rn '\ debugDescription\]'

//CALayer에서도 debugDescription을 사용할 수 있다.
//(lldb) po self.view!.layer.description 의 입력과 (lldb) po self.view!.layer.debugDescription 를 비교해 보면 더 많은 정보를 포함하고 있다.

//(lldb) p self 는 (lldb) po self 와 다른 출력을 낸다. p.69
//먼저 LLDB는 자기 자신의 클래스 이름을 출력한다. 여기서는 Signals.MasterViewController이 된다.
//다음은 LLDB 세션에서 해당 오브젝트를 참조할 때 사용할 수 있는 주소가 온다(ex. 여는 대 괄호 전의 $R2 = 0x00007f88a8c185c0).
//R 뒤의 숫자는 LLDB를 사용할 때 마다 증가한다. 이 참조는 이 세션의 다른 부분에서 이 객체로 돌아가고 싶을 때 유용하게 사용할 수 있다.
//다른 범위에 있고 self가 더 이상 같은 객체를 가리키지 않는 경우
//(lldb) p $R2 를 입력해 아까의 self 객체를 다시 확인할 수 있다((lldb) po $R12 등 다른 입력으로도 사용할 수 있다).
//대괄호에서는 객체에 대한 정보가 입력되어 있다. 여기에서는 MasterViewController의 superclass인 UITableViewController의 세부 정보와
//detailViewController 인스턴스 정보가 있다.

//위에서 확인한 바와 같이 p와 po는 결과가 다르다. p는 형식에 따라 출력이 달라지며 주로 데이터 구조에 대한 출력이다.
//이러한 형식 지정자는 LLDB 내에 있으므로 원하는 경우 변경할 수 있다.
//(lldb) type summary add Signals.MasterViewController --summary-string "Wahoo!"
//이렇게 설정하면, MasterViewController의 인스턴스를 출력할 때마다 "Wahoo!"를 반환한다.
//프로젝트 명인 Signals를 포함하는 것은 Swift에서 namespace 충돌을 방지하기 위해 클래스 이름에 모듈을 포함하므로 Swift 클래스에서는 필수적이다.
//(lldb) type summary clear 으로 위의 명령을 취소할 수 있다.
//이런 식의 형식 변환은 소스 코드가 거의 없는 프로그램을 디버그할 때 유용하다.




//Swift vs Objective-C debugging contexts
//디버깅 시, non-Swift debugging context와 Swift debugging context가 있다.
//Objective-C 코드에서는 non-Swift debugging context, Swift 코드에서는 Swift debugging context가 기본이다.
//(많은 Swift 코드가 Objective-C를 사용하기 때문에, 기본적으로 non-Swift debugging context 인 경우도 많다.)
//(lldb) po [UIApplication sharedApplication] 를 입력하면, 제대로 진행되지 않고 error를 출력한다.
//Swift 코드에서 breakpoint가 작동했으므로 Swift debugging context가 적용되어야 하는데, Objective-C context로 작성했기 때문이다.
//마찬가지로, Objective-C context에서 Swift context를 입력하면 작동하지 않는다.
//-l 옵션을 사용해, Objective-C context로 강제할 수 있다.
//po 표현식이 -O -- 로 매핑되기 때문에 po를 직접 사용할 수 없고, 표현식 자체를 사용해 줘야 한다.
//(lldb) expression -l objc -O -- [UIApplication sharedApplication] 이를 Swift context로 출력하려면
//(lldb) po UIApplication.shared 라고 쓰면 된다.
//다시 resume 한후 같은 (lldb) po UIApplication.shared 를 입력하면 오류가 난다.
//breakpoint를 벗어난 현재 코드가 Objective-C context에 있기 때문에 Swift context를 실행하려하면 오류가 발생하는 것이다.
//디버거에서 현재 일시 중지된 언어를 항상 인지하고 있어야 한다.




//User defined variables
//LLDB는 객체를 출력할 때, 자동으로 local 변수를 생성한다. 여기에서 자신만의 변수를 설정해 줄 수 있다.
//(lldb) po id test = [NSObject new] 이를 실행하면, 새 NSObject를 생성하고, test라는 변수에 저장한다.
//하지만 (lldb) po test 를 입력하면 error가 난다. LLBD에서 변수를 사용할 때는 $를 써야 한다.
//따라서 (lldb) po id $test = [NSObject new] 로 선언하고 (lldb) po $test 로 출력해야 한다.

//Swift context에서는 po 표현식을 풀어 써줘야 한다. (lldb) expression -l swift -O -- $test
//(lldb) exppression -l swift -O -- $test.description 하지만 이 구문은 오류가 난다.
//Objective-C context 에서 LLDB 변수를 만든 다음 Swift context로 이동하는 경우, 모든 것이 "올바르게 작동" 한다고 보장할 수 없다.
//Objective-C와 Swift from LLDB 간의 브리징은 개선 중이며 시간이 버전이 업데이트 될 수록 점차 호환될 것이다.

//LLDB에서 변수를 만들면, 객체에 대한 참조를 가져와서 임의의 메서드를 실행(디버그) 해 볼 수 있다.
//Symbolic breakpoint를 추가해 Symbol에 Signals.MasterContainerViewController.viewDidLoad() -> () 를 설정한다. p.74
//매개 변수 및, 배개 변수 반환 형식에 대한 공백도 같이 써줘야 한다(MasterContainerViewController는 MasterViewController의 super class).
//앱을 다시 빌드하면, MasterContainerViewController.viewDidLoad() 에서 breakpoint가 걸린다. (lldb) p self 를 입력하면
//Swift debugging context 에서 실행한 첫 번째 인수이므로 LLDB는 $R0 변수를 생성한다.
//(lldb) continue 로 진행을 하면, viewDidLoad()를 벗어나기 때문에, self를 사용해도 MasterContainerViewController의 인스턴스 참조를 가져올 수 없다.
//(MasterContainerViewController는 MasterViewController의 super class)
//하지만 아직 $R0 변수가 있기 때문에 이를 사용해 참조를 가져올 수 있다. 이를 가져와 메서드를 실행하고 코드 디버깅을 할 수 있다.
//(lldb) po $R0.title 오류가 난다. LLDB가 Objective-C로 기본 설정되었기 때문에 Swift context를 유지하려면 -l 옵션을 사용해야 한다.
//(lldb) expression -l swift -- $R0.title 네비게이션 바에 보이는 viewController의 title을 출력한다.
//(lldb) expression -l swift -- $R0.title = "💩💩💩💩💩" 이후 (lldb) continue 를 입력하면, 네비게이션 바의 title이 바뀐 것을 확인할 수 있다.
//이 기능은 디버깅 중일 때, 특정 입력이 있는 함수를 단계별로 실행하여 작동 방법을 확인하는 경우 유용하다.
//여전히 viewDidLoad에 symbolic breakpoint가 있을 때, 일시 중지 시키고 다음을 입력한다.
//(lldb) expression -l swift -O -- $R0.viewDidLoad()
//아무 변화가 없다. MasterContainerViewController가 메서드를 실행했지만, 기본적으로 LLDB는 명령을 실행할 때, breakpoint를 무시한다.
//-i 옵션으로 이를 비활성화 할 수 있다.
//(lldb) expression -l swift -O -i 0 -- $R0.viewDidLoad() 이전에 작성한 viewDidLoad() 의 breakpoint에서 중단된다.
//이 방법은 논리를 테스트하는데 유용하다. ex. 다른 입력을 처리하는 방법을 알기 위해 함수에 다른 매개 변수를 제공하여 테스트 구동 디버깅을 구현한다.




//Type formatting
//LLDB에서는 기본 데이터 유형의 출력 형식을 지정할 수 있다. C언어의 포맷팅을 사용한다.
//(lldb) expression -G x -- 10 이 옵션(-G)는 원하는 출력의 형식을 LLDB에 알려준다. G는 GDB(LLDB 이전의 디버거) 형식을 나타낸다. x는 16진수를 나타낸다.
//즉 10을 16진수로 출력한다.
//(lldb) p/x 10 로 더 간결하게 나타낼 수 있다.
//(lldb) p/t 10 는 10을 2진수로 나타낸다. /t 는 이진 형식을 지정한다.
//(lldb) p/t -10 , (lldb) p/t 10.0 등으로도 쓸 수 있다.
//(lldb) p/d 'D' 로 ASCII 코드도 출력할 수 있다. /d는 10진수 형식을 지정한다.
//(lldb) p/c 1430672467 로 문자로 변환할 수도 있다. /c 는 char 형식을 지정한다. 숫자를 2진수로 바꿔 8비트로 분할하여 각 ASCII 코드를 가져온다.

//• x: hexadecimal • d: decimal • u: unsigned decimal • o: octal • t: binary • a: address • c: character constant • f: float • s: string
//https://sourceware.org/gdb/ onlinedocs/gdb/Output-Formats.html

//추가적인 LLDB 포맷을 사용할 수도 있다. GDB 형식 구문은 사용할 수 없게 된다.
//(lldb) expression -f Y -- 1430672467

//• B: boolean • b: binary • y: bytes • Y: bytes with ASCII • c: character • C: printable character • F: complex float • s: c-string
//• i: decimal • E: enumeration • x: hex • f: float • o: octal • O: OSType • U: unicode16 • u: unsigned decimal • p: pointer
//http://lldb.llvm.org/varformats.html




//**************************************** Ch6. Thread, Frame & Stepping Around ****************************************
//Stack 101
//컴퓨터 프로그램이 실행되면, 스택과 힙에 값을 저장한다. 스택은 현재 실행중인 코드에 대한 참조를 저장하는 LIFO(Last-In-First-Out) 큐이다.
//LIFO는 가장 최근에 추가된 것이 먼저 제거된다. 스택 포인터는 현재 스택의 맨 위를 가리킨다.
//스택 포인터는 다음 가져올 객체의 위치 또는 다음 객체를 배치할 위치를 알려준다. p.81




//Examining the stackʼs frames
//실제 iOS 디바이스로 빌드하면, 시뮬레이터에서 빌드한 것과 어셈블리가 달라진다. 이는 시뮬레이터가 Mac의 기본 명령어 세트인 x86_64(구형 디바이스 시뮬레이터에선 i386)를 사용하지만
//실제 디바이스는 ARM 아키텍처를 사용하기 때문이다.
//Symbolic breakpoint를 추가한다. Symbol 란에 Signals.MasterViewController.viewWillAppear(Swift.Bool) -> () 를 추가한다. p.82
//이는 MasterViewController의 viewWillAppear(_:) 메서드에 Symbolic breakpoint를 추가한다.
//build를 실행해, viewWillAppear의 breakpoint에서 멈추면, Xcode 왼쪽 패널에서 Stack trace를 살펴 볼 수 있다(⌘ + 7).
//패널 하단에 위치한 필터의 오른쪽에 3개의 버튼이 모두 비활성화되어 있는지 확인한다. 각 버튼이 필터링을 하는데, 비공개 되어 있는 코드에 대해서도 확인해야 할 부분이 있으므로 비활성화한다.
//디버그 네비게이터 패널 내에서 stack trace가 나타나 stack frame 목록을 보여준다. 가장 첫 번째는 viewWillAppear(_:) 이고,
//다음은 Swift/Objective-C 브리징인 @objc MasterViewController.viewWillAppear(Bool) -> () 이다.
//이 메서드는 Objective-C가 Swift 코드를 사용할 수 있도록 자동 생성된다. 이후 UIKit에서 사용되는 Objective-C 코드 stack frame이 이어진다.
//CoreAnimation에 속한 C++ 코드를 볼 수도 있다. CoreFoundation의 CFRunLoop 이름을 포함하는 몇 가지 메서드가 실행된 후, main function이 실행된다.
//(Swift 프로그램도 main function이 있다. 단지 숨겨져 있을 뿐이다.)
//LLDB에서도 stack tracking을 할 수 있다. Xcode의 패널에서 보이는 것은 간단하게 요약한 것이다.
//(lldb) thread backtrace 이 작업을 (lldb) bt 로 줄여써도 동일하다(하지만 실제로는 다른 명령이다). 네비게이터에서 보던 것과 같은 출력이 표시된다.
//(lldb) frame info 디버그 네비게이션과 출력이 일치한다. LLDB를 이용하면, 상세한 정보를 세밀하게 제어할 수 있다.
//또한 이러한 명령을 유용하게 사용할 수 있는 사용자 정의 LLDB 스크립트를 작성할 수 있다.
//Debug Navigator에 표시된 숫자를 사용해 stack frame에 연결할 수 있다.
//(lldb) frame select 1 스택의 인덱스 1에 있는 메서드인 @objc 브리징 메서드로 이동한다.
//objc 브리징은 Objective-C의 동적인 특성과 상호작용하기 위해 Swift 컴파일러에서 생성된 방법이다. Swift 3.2 이전 버전에서는
//모든 NSObject에는 @objc 브리징 메서드가 생성되어 있었다. Swift4의 기본 빌드 설정을 사용하면 Objective-C의 NSObject 라도
//@objc (혹은 @objcMembers) 특성이 있어야 브리징 메서드를 생성할 수 있다.
//(lldb) frame select 1 를 실행하면, 어셈블리 코드를 확인할 수 있다. 멈춰진 녹선 라인의 명령을 기억해 둔다.
//그 바로 앞에 viewWillAppear(_:)을 실행하는 callq 명령이 있다(breakpoint를 이곳에 설정했기 때문).




//Stepping
//LLDB에서 프로그램을 일시 중지 시켰을 때, 프로그램을 단계별로 진행할 수 있다. 각각의 프로그램 코드를 계속 실행 하면서, 작은 덩어리로 검사가 가능하다.

//Stepping over
//Stepping over를 사용하면, 디버거가 현재 일시 중지된 컨텍스트에서 다음 코드(일반 적으로 다음 행)으로 이동한다.
//즉, 현재 명령문이 다른 함수를 호출하면, LLDB는 그 함수가 완료되거나 반환될 때까지 실행된다.
//(lldb) run 이렇게 하면, Xcode를 다시 컴파일할 필요없이 다시 프로그램을 시작한다.
//(lldb) next 디버거가 한 줄 앞으로(breakpoint의 다음 행으로) 이동한다.

//Stepping in
//Stepping in 은 다음 명령이 함수 호출이면, 디버거가 해당 함수의 시작으로 이동한 후 일시 중지한다.
//(lldb) run 이렇게 하면, Xcode를 다시 컴파일할 필요없이 다시 프로그램을 시작한다.
//(lldb) step 을 입력하면, 여기에서는 처음 breakpoint에 설정된 부분에 바로 함수 호출이 있으므로, stepping in이 제대로 되지 않는다.
//이런 경우에는 step into 보다 step over 같이 진행된다. 이는 LLDB가 기본적으로 해당 함수에 대한 디버그 symbol이 없으면 stepping into를 무시하기 때문이다.
//이 경우, 함수 호출은 UIKit에 있으며 debug symbol이 따로 없다.
//하지만 debug symbol이 없는 함수로 들어 갈때, LLDB가 어떻게 작동하는지 설정할 수 있다.
//(lldb) settings show target.process.thread.step-in-avoid-nodebug
//이 앖이 true이면, stepping in 은 step over 처럼 작동한다. 이 설정은 변경하거나 무시하도록 할 수 있다.
//(lldb) step -a0 이렇게 하면 디버그 symbol 여부에 관계없이 LLDB가 단계별로 진행된다.

//Stepping out
//Stepping out은 함수가 그 지속 시간 동안 계속되고, 반환되었을 때 멈추는 것을 의미한다.
//스택 관점에서 실행은 stack frame이 pop 될때까지 계속된다.
//(lldb) finish 를 입력하면, 디버거가 stack trace 에서 하나의 함수를 일시중지 한 것임을 알 수 있다. 몇 번 더 반복해 실행해 보면 stack이 하나씩 줄어드는 것을 볼 수 있다.
//finish는 LLDB가 현재 함수에서 빠져나오도록 한다.

//Stepping in the Xcode GUI
//GUI 버튼으로도 위의 기능들을 대신할 수 있다. 순서대로 step over, step in, step out 이다.
//Control 과 Shift 키를 누른 상태에서 다른 스레드의 실행을 수동으로 제어할 수 있다.
//이렇게 하면, 나머지 스레드가 일시 정지된 상태에서 디버거가 일시 중지된 스레드를 단계별로 실행한다.
//네트워킹이나 Grand Central Dispatch(GCD) 같이 디버깅하기 어려운 동시성 코드의 경우 사용할 수 있다.
//LLDB에서는 --run-mode 옵션이나 간단히 -m 옵션을 사용해 같은 효과를 낼 수 있다.




//Examining data in the stack
//frame variable 명령은 실행 파일의 헤더에 있는 디버그 symbol 정보를 가져온다(혹은 dYSM). 특정 스택 프레임에 대한 정보를 출력한다.
//디버그 정보로 frame variable 명령은 적절한 옵션을 사용해 프로그램의 전역 변수뿐 아니라 함수의 모든 변수 범위를 쉽게 알 수 있다.
//다시 빌드 해서 viewWillAppear(_:) 에서 breakpoint가 멈춘 후, 스택의 가장 위(0)로 이동한다(네비게이션에서 선택하거나).
//(lldn) frame select 0 혹은 (lldb) f 0 를 입력한다. 그리고
//(lldb) frame variable 를 입력하면, 여러 정보를 볼 수 있다. 현재 스택 프레임과 코드 행에서 사용할 수 있는 변수를 출력한다.
//이 출력은 Console창 왼쪽 패널의 Variables View의 내용과 일치하는 것을 알 수 있다. p.88
//(lldb) frame variable -F self 이는 현재 self(MasterViewController)가 사용할 수 있는 모든 private 변수를 출력한다(-F는 flat의 약자).
//이는 pulic 변수를 탐색하는 좋은 방법 중 하나이다.
