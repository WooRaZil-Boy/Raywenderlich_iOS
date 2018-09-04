//debugserver 프로그램 (Xcode.app/Contents/SharedFrameworks/LLDB.framework/Resources/)은 대상 프로세스에 연결하는 역할을 담당한다.
//원경 장치에서 실행중인 iOS, watchOS, tvOS 응용 프로그램과 같은 원격 프로세스는 원격 디버그 서버가 해당 원격 장치에서 시작한다.
//LLDB는 응용 프로그램을 디버깅 할 때 모든 상호 작용을 처리하기 위해 디버그 서버를 시작, 연결 및 조정하는 업무를 수행한다.




//Attaching to an existing process
//lldb -n Xcode 로 LLDB에 프로세스를 attach 할 수 있다.
//실행중인 프로그램의 프로세스 식별자 또는 PID를 제공하여 연결할 수도 있다.
//터미널에서 pgrep -x Xcode 를 입력하면 해당 프로세스(Xcode)에 대한 PID를 출력한다.
//출력된 PID를 사용해 LLDB에 프로레스를 attach 할 수 있다. lldb -p 89944




//Attaching to a future process
//위의 lldb -n Xcode, lldb -p 89944 명령들은 실행중인 프로세스만 처리한다. Xcode(프로세스)가 실행 중이 아니거나 이미 디버거에 연결되어 있으면 명령이 실패한다.
//PID를 모르는 경우 -w 매개변수를 사용해 제공된 기준과 일치하는 PID 또는 실행 파일 이름으로 프로세스가 시작될 때까지 LLDB를 대기하도록 할 수 있다.
//터미널에서 Ctrl + D 를 입력하면 해당 세션을 종료한다.
//lldb -n Finder -w 이렇게 입력하면, 다음에 시작할 때마다 Finder라는 프로세스에 연결하도록 LLDB에 지시한다.
//다른 탭을 생성하고 pkill Finder 를 입력하면, Finder 프로세스가 강제 종료되고 다시 시작된다.
//macOS가 종료되면, Finder가 자동으로 다시 실행된다.
//프로세스에 attach하는 또 다른 방법은 실행 파일의 경로를 수동으로 지정하는 것이다.
//lldb -f /System/Library/CoreServices/Finder.app/Contents/MacOS/Finder
//이후 프로세스가 연결되면 (lldb) process launch 를 입력한다. Finder가 실행된다.




//Options while launching
//프로세스를 시작하는 명령에는 많은 옵션이 제공된다. help process launch 로 항목을 확인해 볼 수 있다.
//lldb -f /bin/ls 를 입력하면, /bin/ls(파일 목록 명령) 를 대상 실행 파일로 사용한다.
//-f 옵션을 생략하면 LLDB는 첫 번째 인수를 시작하고 디버그 할 실행 파일로 자동 유추한다.
//터미널 실행 파일을 디버깅 할 때 lldb $(which ls) 를 입력하고 lldb /bin/ls 으로 변환한다.
//(lldb) process launch 로 ls 를 launch 한다.
//출력으로 ls 프로세스가 시작된 디렉토리에서 launch 된다. LLDB에 -w 옵션으로 시작 위치를 알려 현재 작업 디렉토리를 변경할 수 있다.
//(lldb) process launch -w /Applications
//이렇게 하면 /Applications 디렉토리에서 ls 프로세스가 시작된다. 이는  $ cd /Applications 후에 $ ls 한 것과 출력이 같다.
//이와 같은 작업을 수행하는 또 다른 방법으로는 LLDB가 디렉토리를 지정해 프로그램을 실행하도록 지시하는 대신, 인수를 프로그램에 직접 전달하는 것이다.
//(lldb) process launch -- /Applications
//이는 $ ls /Applications 를 입력한 것과 결과가 같다. 이것은 시작 디렉토리를 변경하는 대신 인수를 지정한 것이다.
//이를 (lldb) process launch -- ~/Desktop 등으로 입력하면, 오류가 발생한다. 인수에서 물결표(tilde)를 사용하려면 쉘이 필요하기 때문이다.
//대신 (lldb) process launch -X true -- ~/Desktop 이렇게 입력한다.
//-X 옵션은 물결표(tilde)와 같이 사용자가 제공한 모든 쉘 인수를 확장한다. 이를 간단히 run 으로 줄여 쓸 수 있다.
//즉 'run'은 'process launch -X true --' 의 약어이다.
//(lldb) run ~/Desktop 은 (lldb) process launch -X true -- ~/Desktop 와 같은 결과를 출력한다.
//콘솔 출력을 다른 위치로 변경하는 것은 -e로 stderr의 위치(세션)를 지정해서 할 수 있다(챕터 1). stdout을 변경하는 것은 -o를 사용한다.
//(lldb) process launch -o /tmp/ls_output.txt -- /Applications
//다른 터미널 탭을 생성하고 cat /tmp/ls_output.txt 를 입력한다(해당 경로의 파일을 읽는다).
//stdin에 대해서도 -i 옵션이 있다.
//(lldb) target delete 그러면 ls가 target에서 해제된다.
//(lldb) target create /usr/bin/wc
// /usr/bin/wc 가 새로운 target으로 설정된다. wc는 stdin에 주어진 입력에서 문자, 단어 또는 행을 세는 데 사용한다.
//다른 터미널 탭에서 echo "hello world" > /tmp/wc_input.txt 로 해당 경로의 파일에 문자를 입력한다.
//(lldb) process launch -i /tmp/wc_input.txt 이는 $ wc < /tmp/wc_input.txt 를 입력한 것과 같다. 행, 단어, 문자의 수를 출력한다.
//stdin (standard input)를 원하지 않는 경우도 있다(Xcode 등의 GUI 프로그램을 사용하는 경우).
//인수 없이 target이 wc인 상태에서 (lldb) run 를 입력하면, 프로그램은 stdin에서 무언가 읽을 것으로 예상하기에 그냥 대기상태가 된다.
//이 경우에는 문자를 입력하고, Return 키를 누른 후, Control + D 를 눌러 전송을 끝내야 한다.
//(lldb) process launch -n
//-n 옵션은 LLDB에 표준 입력을 생성하지 않도록 한다. 따라서 wc는 작업을 할 데이터가 없게 되고 즉시 종료된다.
