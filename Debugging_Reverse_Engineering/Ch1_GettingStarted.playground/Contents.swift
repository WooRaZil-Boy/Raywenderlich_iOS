//Getting around Rootless
//Apple은 Rootless로 시스템을 보호한다.
//하지만, 디버깅을 Rootless가 차단하는 경우도 있기에 경우에 따라서 Rootless를 해제하고 디버깅해야 한다.
//Rootles를 사용하도록 설정한 경우, 대부분의 경우에는 Apple 프로그램에 연결할 수 없지만, iOS 시뮬레이터의 앱은 예외가 된다.

//Disabling Rootless
//Rootless를 해제하는 방법은 다음과 같다.
//1. Mac을 재시동한다.
//2. Apple 로고가 나타날 때까지 Command + R을 누른다. 그러면 복구모드로 전환된다.
//3. 복구 모드에서 Terminal을 실행한다.
//4. Terminal에서 다음과 같이 입력한다. : csrutil disable; reboot
//5. Rootless가 해제된 상태로 Mac이 재시동된다.
//6. 같은 방법으로 3까지 진행 후 csrutil enable 를 입력하면 다시 Rootless를 활성화할 수 있다.




//Attaching LLDB to Xcode
//lldb를 실행 시킨후 (lldb)가 떠 있는 행에서 file /Applications/Xcode.app/Contents/MacOS/Xcode
//를 입력하면, lldb의 실행 타겟이 Xcode로 설정된다.

//터미널에서 다른 탭을 생성해 tty를 입력해 터미널 세션의 주소를 알 수 있다.
//(lldb) echo "hello debugger" 1>/dev/ttys027(세선 주소) 를 입력해, 해당 세션에 메시지를 보낼 수 있다.

//Xcode를 lldb의 타겟으로 설정하고 해당 세션의 주소를 알고 있다면,
//(lldb) process launch -e /dev/ttys027 -- 를 입력해 해당 세션에서 Xcode를 실행할 수 있다.
//-e로 stderr의 위치(세션)를 지정해 준다. 이후 NSLog나 print 등이 stderr 터미널에서 출력 된다.




//A "Swiftly" changing landscape
//Xcode9 에는 Swift가 포함된 프레임워크가 40 여 개 정도 있다.
//lldb에서 이 정보를 조회해 볼 수 있다.
//(lldb) script print "\n".join([i.file.basename for i in lldb.target.modules if i.FindSection("__swift3_typeref")])
//위와 같이 파이썬 언어로, lldb 스크립트를 작성할 수 있다.

//Finding a class with a click
//디버깅 시 Cocoa SDK와 Objective-C에 대한 지식이 많은 도움을 줄 수 있다.
//ex. [NSView hitTest :] 는 실행 루프에서 터치(혹은 클릭) 이벤트에 대해 처리된 객체를 반환하는 메서드 이다.
//이 메서드는 NSView에 추가될 때 트리거 되고, 이 터치를 처리하는 가장 뒤의 subview에 재귀적으로 호출된다.
//이런 지식을 사용하면, 터치한 뷰의 클래스를 결정하는 데 도움이 된다.
//(lldb) b -[NSView hitTest:] 로 breakpoint를 생성할 수 있다([NSView hitTest:] 에 생성).
//(lldb) c (혹은 continue)를 사용해 resume 할 수 있다.
//breakpoint가 설정된 이후에 Xcode 의 아무 곳이나 클릭하면, breakpoint 에 걸리며 일시 중지 된다.
//(lldb) po $rdi 를 입력해, RDI CPU register를 조회한다. 어느 뷰에서 breakpoint가 걸렸는지 알 수 있다.
//이 명령은 lldb가 RDI 어셈블리 레지스터에 저장된 내용이 참조하는 메모리 주소에 개체의 내용을 출력하도록 한다.
//po는 print object의 약자이다. p는 단순히 RDI의 내용을 인쇄한다.
//po는 NSObject의 description 혹은 debugDescription 메소드를 사용할 때 유용하다.
//lldb의 $rdi 레지스터가 [hitTest:]가 호출된 NSView의 subclass 인스턴스가 포함되어 있다는 것을 알려준다.
//이 상태 에서 다시 (lldb) c 를 입력하면 계속 진행하는 대신 Xcode는 hitTest에 대한 또다른 breeakpoint를 찾고 멈춘다.
//이는 [hitTest:] 메서드가 터치된 부모 뷰 내의 모든 subview에 대해 해당 메서드를 재귀적으로 호출하기 때문이다.

//Filter breakpoints for important content
//Xcode를 구성하는 NSView는 매우 많기 때문에 원하는 대상과 관련된 NSView에서만 멈출 수 있어야 한다.
//자주 호출되는 메서드를 디버깅할 때 이 방법을 사용하면 된다. 실제로 찾고 있는 것을 정확히 찾는데 도움이 된다.
//Xcode9 에서 Xcode IDE에 코드를 시각적으로 표시하는 클래스는 IDEPegasusSourceEditor 모듈의 SourceCodeEditorView 이다.
//위에서 본 것과 같이 Swift로 만들어진 클래스로 비주얼 코디네이터의 역할을 수행하여
//모든 코드를 다른 비공개 클래스에 전달해 응용 프로그램을 컴파일하고 작성하는 데 도움을 주는 클래스이다.
//특정 조건에서만 중단하도록 breakpoint 조건을 추가해 줄 수 있다(여기서는 NSView의 인스턴스를 터치할 때만 되도록 수정한다).
//- [NSView hitTest :] 의 breakpoint가 있고 이것이 lldb 세션의 유일하게 활성화된 breakpoint인 경우,
//다음 명령을 사용해 해당 breakpoint를 수정할 수 있다.
//(lldb) breakpoint modify 1 -c '(BOOL)[$rdi isKindOfClass:(id)NSClassFromString(@"IDEPegasusSourceEditor.SourceCodeEditorView")]'
//(lldb) breakpoint modify 1 -c ‘(BOOL)[$rdi isKindOfClass:(id)NSClassFromString(@“SourceEditor.SourceEditorView”)]’
//(lldb) breakpoint modify 1 -c ‘(BOOL)[$rdi isKindOfClass:(id)NSClassFromString(@“IDESourceEditor.IDESourceEditorView”)]’
//이 명령은 breakpoint 1을 수정하고 [NSView hitTest :]가 실행될 때마다 평가되는 조건을 만든다.
//해당 조건이 true가 될 때에만 breakpoint가 걸려 일시중지 된다.
//위의 조건은 NSView의 인스턴스가 IDESourceEditor.IDESourceEditorView 인지 확인하는 것이다.
//Swift에서는 포인터 참조를 숨기기 때문에 (lldb) po $rdi 대신 (lldb) p/x $rdi 으로 주소를 알아낼 수 있다.
//rdi는 Objective-C NSObject를 가리키기 때문에 레지스터 대신 해당 주소를 지정하여 동일한 정보를 얻을 수 있다.
//(lldb) po [$rdi setHidden:!(BOOL)[$rdi isHidden]]; [CATransaction flush] 를 입력하면 해당 화면을 감춘다.
//이를 통해, 이전 breakpoint에서 제대로 된 View를 찾았는지 확인할 수 있다.
//(lldb) p/x $rdi 를 사용했을 때 $와 16진수 사이의 숫자는 해당 주소에 대한 참조로 사용할 수 있다.
//이것은 디버그나 프로그램을 더 진행해 rdi 레지스터가 다른 것을 가리키고 있을 때, 나중에 NSView를 다시 참조하려 할 때 유용하다.
//(lldb) po [$rdi superclass] (lldb) po [[$rdi superclass] superclass]
//NSView의 subclass인지 바로 알 수 없다. 반복적으로 클래스의 super class를 파악해 이 인스턴스가 NSView subclass 인지 확인할 수 있다.
//(lldb) ex -l swift -- import Foundation
//(lldb) ex -l swift -- import AppKit
//ex는 expression의 약자로 코드를 평가할 수 있으며 p po 명령어의 기초이다.
//-l swift는 LLDB가 명령을 Swift 코드로 해석하도록 한다.
//따라서 위의 코드로 Swift로 두 모듈의 메서드를 호출하기 적절한 헤더로 가져왔다.
//(lldb) ex -l swift -o -- unsafeBitCast(0x000000011e7044e0, to: NSObject.self)
//(lldb) ex -l swift -o -- unsafeBitCast(0x000000011e7044e0, to: NSObject.self) is NSView
//위 코드는 해당 인스턴스가 NSView의 subclass 인지 Swift 코드로 확인한다.
//Swift를 사용하려면 훨씬 더 많은 타이핑이 필요하다. LLDB는 Objective-C가 기본값이다. 이것을 Swift로 바꿀 수 있지만 더 복잡해 진다.
//NSView의 subclass 이므로 NSView의 모든 메서드를 적용 가능하다.
//(lldb) po [$rdi string]
//Xcode에서 열려 있는 파일의 내용을 인쇄한다.
//image lookup 명령어를 regular expression과 함께 사용하면 해당 조건을 검색할 수 있다.
//(lldb) image lookup -rn objc\sIDESourceEditor.IDESourceEditorView.*getter
//objc 브릿지로 시작하고 "getter" 단어가 포함된 IDESourceEditorView의 모든 메서드를 검색한다.
//해당 출력을 보면서 뒤에 메서드를 파악해 코드를 실행할 수 있다.
//(lldb) po [$rdi hostingEditor]
//(lldb) po [$rdi language]
//method signature에 @objc가 포함되어 있는 Swift 메서드는 Objective-C로 사용할 수 있음을 의미한다.

//Executing private Swift methods
//일반적으로 LLDB가 코드베이스와 상호작용할 때 모듈의 모듈 맵(.modulemap)에 대해 알고 있어야 한다.
//이는 LLBD가 실행할 수 있는 코드와 실행할 수 없는 코드를 파악하기 위해 필요한 정보이기도 하다.
//Swift LLDB’s code-execution-compiler(JIT) 는 모듈 맵으로 해당 프레임 워크 내의 메서드와 상호작용할 수 있다.
//스위프트로만 만들어진 모듈의 경우에서의 사용법은
//위의 (lldb) ex -l swift -- import Foundation (lldb) ex -l swift -- import AppKit 같은 방법을 사용한다.
//LLDB에서 Swift 코드를 실행할 때 해당 모듈 맵이 없으면 코드를 실행할 수 없다.
//예를 들어 IDESourceEditor 모듈에는 Swift 코드에 액세스하기 위해 가져올 수 있는 .modulemap이 없다.
//따라서 mangled function 의 이름을 파악해 C’s extern을 사용해 이를 선언하고 실행해야 한다.
//브리징 메서드를 검색하는 것은 다음과 같다.
//(lldb) image lookup -rvn  objc\sIDESourceEditor.IDESourceEditorView.insertText\(Any\)
//이러면 메서드 에 대한 출력이 덤프된다.
//출력 맨 아래, mangled Swift name이 있다. 이 값을 복사하고 LLDB에서 외부적으로 선언한다.
//(lldb) po extern void _T012SourceEditor0aB4ViewC10insertTextyypFTo(long, char *,id);
//(lldb) po _T012SourceEditor0aB4ViewC10insertTextyypFTo($rdi,0,@"wahahahahah")
//SourceCodeEditorView에서 커서가 위치한 곳을 찾고 코드에서 다른 내용 검색하면 IDE에 wahahahahah가 표시된다.
//LLDB가 Objective-C를 사용하는 것이 Swift를 사용하는 것보다 훨씬 안정적이고 속도도 빠르다.
