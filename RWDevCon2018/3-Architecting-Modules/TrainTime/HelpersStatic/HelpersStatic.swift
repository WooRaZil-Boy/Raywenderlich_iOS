///// Copyright (c) 2018년 Razeware LLC
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

class HelpersStatic {

}

//Create a static Helpers library
//동적 프레임워크를 정적 프레임워크로 변환한다.
//Project Editor에서 "+" 버튼을 눌러 새 target을 설정한다.
//iOS > Framework & Library > Cocoa Touch Static Library
//해당 라이브러리(Helpers)에서 필요한 파일들을 이전의 동적 라이브러리 폴더에서 Drag & Drop으로 가져온다.
//target이 맞게 설정되었는지 다시 확인해볼 것
//이전의 동적 라이브러리(Helpers)는 사용하지 않으므로 Project Editor에서 "-" 버튼을 눌러 삭제해 준다.
//다른 프레임워크(UserServiceStatic, InfoServiceStatic)에서 Helpers를 사용하고 있으므로,
//해당 프레임워크들의 선택해 Build Phases > Target Dependencies에서 HelpersStatic을 추가해 준다.
//해당 프로임워크들의 스위프트 코드에서 Helpers로 쓴 부분을 HelpersStatic으로 바꿔준다.
//TrainTime(메인 앱)을 선택하고, General > Linked Frameworks and Libraries에서 정적 라이브러리를 추가해 준다.
//Clean & Build
