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
