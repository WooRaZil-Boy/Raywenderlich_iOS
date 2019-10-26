/// Copyright (c) 2019 Razeware LLC
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

import SwiftUI
import Game

struct ContentView: View {
  @ObservedObject private var game = BullsEyeGame()
    @EnvironmentObject var defaults: UserDefaults //설정 창 위한 변수

  @State private var currentValue = 50.0
  @State private var showAlert = false

  private var alpha: Double {
    abs(Double(game.targetValue) - currentValue) / 100.0
  }

  var body: some View {
    VStack {
      Text("Put the Bull's Eye as close as you can to: \(game.targetValue)")
      HStack {
        Text("0")
        
        if defaults.bool(forKey: "show_hint") { //설정에서 힌트보기 상태라면,
            Slider(value: $currentValue, in: 1.0...100.0, step: 1.0)
              .background(Color.blue)
                .opacity(abs((Double(self.game.targetValue) - self.currentValue)/100.0))
        } else {
            Slider(value: $currentValue, in: 0.0...100.0, step: 1.0)
        }
        //Slider에 if-else Condition을 추가한다.
        //Slider를 Command-click 한 후, Make Conditional를 선택하면 된다.
        //Canvas가 있는 상태여야, 해당 메뉴가 표시된다.
        
        Text("100")
      }
      .padding(.horizontal)
      Button(action: {
        self.showAlert = true
        self.game.checkGuess(Int(self.currentValue))
      }) {
        Text("Hit Me!")
      }.alert(isPresented: $showAlert) {
        Alert(title: Text("Your Score"), message: Text(String(game.scoreRound)),
              dismissButton: .default(Text("OK"), action: {
                self.game.startNewRound()
                self.currentValue = 50.0
              }))
      }
      .padding()
      HStack {
        Text("Total Score: \(game.scoreTotal)")
        Text("Round: \(game.round)")
      }
    }
  }
}

struct ContentView_Previews : PreviewProvider {
  static var previews: some View {
    ContentView()
    //      .previewLayout(.fixed(width: 568, height: 320))
  }
}

//-----------------------------------------------------------------------------------
//Chapter 5: The Apple Ecosystem

//SwiftUI로 Cross-platform 앱을 쉽게 개발할 수 있지만, 장치에 따라 최적화를 따로 해 줘야 한다.
//iOS 외의 기기에 맞게 앱을 수정하고, 각 플랫폼의 장단점을 학습히한다.




//Getting started
//1 ~ 100 사이의 임의로 주어진 값을 Slider에서 추측해 점수를 확인하는 앱이다.
//Alert을 확인할 때마다 새 라운드가 시작된다.
//기본 앱은 Slider 배경의 Alpha 값을 사용해 사용자에게 지속적인 피드백을 준다.
//Watch 용 앱은 WatchKit Extension의 ContentView.swift에서 확인할 수 있다.
//scheme를 WatchKit App으로 바꿔줘야 올바르게 preview가 표시된다.
//Watch App의 ContentView는 iOS앱과 동일하지만, Slider가 -, +와 Button으로 구현되어 있다.
//두 앱은 Target Membership을 사용해서, BullsEyeGame Model 클래스를 공유한다.




//Creating a Swift package
//Target membership은 Target이 한 두개의 파일만을 공유하는 경우 적합하다.
//그러나, 더 많은 기능이 추가되면 번거로워지므로, Package를 구성하는 것이 좋다.
//Package를 사용하는 것이, Apple 플랫폼에서 공유하기 더 쉽다.
//BullsEyeGame의 Swift Package를 만든다.
//File ▸ New ▸ Swift Package ... 를 선택해 Swift Package를 생성한다.
//Add to에 해당 프로젝트를, Group에 해당 폴더를 선택해 준다.
//Readme와 Package.swift가 추가 된다.
//생성한 Game Package는 Local Package이다.
//일반적인 Swift Package의 사용 방법은 Storage URL로 원격으로 연결하는 것이다.

//Customizing your Game package
//BullsEyeGame.swift를 Game Package로 이동 한다. BullsEyeGame의 모듈이 바뀌었기 때문에
//public으로 교체 해줘야 한다.

//Versioning your Game package
//Package.swift의 manifest 파일을 열어, 빌드 방법을 지정해 줘야 한다.
//버전 정보를 입력하지 않으면, Xcode는 코드가 새로운 OS에서 실행될 경우,
//@available 구문을 계속해서 추가한다.

//Linking your Game package library
//products 매개변수에서는 앱과 연결하는 라이브러리를 정의한다.
//해당 라이브러리를 앱과 연결하려면, iOS app target에서 Frameworks를 연다.
//Libraries and Embedded Content 세션에서 해당 프레임워크를 추가해 준다.
//WatchKit Extension target에서도 같은 작업을 해 준다.

//Importing your Game package module
//새롭게 생성한 패키지를 사용하려면 해당 모듈을 import 해야 한다.
//iOS 앱과 Watch 앱의 ContentView.swift에서 해당 모듈을 import 한다.
//해당 모듈을 찾지 못하는 경우가에는 프로젝트를 클린 후, 다시 빌드한다.
//그럼에도 해결되지 않는 경우에는 캐시를 지워준다.
//Derived Data 폴더(Preferences ▸ Locations)를 지워 주면 된다.
//Game 패키지의 BullsEyeGame.swift 파일이 각 플랫폼에서 실행된다.
//패키지는 플랙폼에 독립적이므로, 명시적으로 재구성해 줄 필요가 없다.

//Creating a GameView package
//BullsEyeGame.swift와 ContentView.swift로 GameView 패키지를 생성한다.
//이를 활용해서 이후에 macOS 앱에서 사용할 수 있도록 한다.
//새로운 GameView package를 생성하고, Add to는 don’t add it to any project를 선택한다.
//필요하 파일을 복사한다. drag-and-drop을 해도, 제대로 복사 되지 않는 경우에는 Finder에서 직접 복사한다.
//해당 프로젝트의 ContentView.swift와 Game 패키지의 BullsEyeGame.swift를 복사한다.
//GameView 패키지를 열어, ContentView.swift를 편집한다.
//이전과 마찬가지로 필요한 클래스와 변수를 public으로 선언해 다른 모듈에서 접근 가능하도록 한다.
//package.swift에서 플랫폼을 설정해 준다.




//Designing for the strengths of each platform
//SwiftUI는 여러 플랫폼에 대응하는 앱을 개발할 수 있다.
//Toggle, Picker, Slider 같은 컨트롤은 플랫폼마다 다르게 보여지지만,
//데이터 관계는 동일하므로 다른 플랫폼 앱에 쉽게 적용할 수 있다.

//watchOS
//Watch는 적절한 정보를 신속하게 얻을 수 있다. 화면이 매우 작기 때문에 중요한 정보만 표시해야 한다.
//탐색을 간소화해서 두 세번의 탭으로 중요한 정보를 얻을 수 있도록 해야 한다.
//digital crown(물리 wheel)을 사용할 수 있다.

//macOS/iPadOS
//보다 자세한 작업을 할 수 있다. Mac은 큰 화면과 키보드가 있어, 단축키를 사용해 시간을 줄일 수 있다.
//여러 개의 창을 활용할 수도 있다.

//tvOS
//매우 큰 화면에서 실행되고, 일반적으로 멀리서 사용한다. 두 개 이상의 Viewer 가 있을 수 있다.
//또한 한 번의 세션이 상당히 길 수 있다. 이미지와 비디오의 전체 화면 실행에 가장 적합하지만,
//많은 텍스트를 읽거나 쓰는 것은 적합하지 않다. 모바일이 아니므로, geofencing features 이나
//location-based notification을 사용하지 않는다.
//컨트롤러를 별도로 사용하기 때문에 탐색이 간소화되어야 한다.
//SwiftUI를 사용하면, play, pause, exit 버튼에 액세스할 수 있다.
//컨트롤러의 구조 디자인이 달라질 수 있다. ex. TableView를 사용하는 경우,
//iOS에서는 계층 구조를 탐색할 때, 탭을 계속 표시하도록 최상위 레벨에 위치하지만,
//tvOS 에서는 NavigationView를 포함시킨다. 따라서 탭이 사라져 전체 화면에서 실행된다.

//Improving the watchOS app
//iOS용 앱으로 Watch에 그대로 적용해도 실행이 되지만, 화면이 작기 때문에 몇 가지 문제점이 있다.
//텍스트를 짧게 수정하고, digital crown을 사용해서 slider를 움직일 수 있도록 수정한다.

//Extending the Mac Catalyst app
//Catalyst를 사용해 iOS 앱을 쉽게 MacOS 앱으로 실행할 수 있다.
//Project 설정에서 Signing and Capabilities 탭의 Bundle Identifier에 서명을 해야 한다.
//이후, Deployment Info 에서 Mac을 체크한다. 이후, scheme를 Mac으로 변경하고 build하면 된다.

//iOS Settings == macOS Preferences
//Catalyst로 실행된 앱의 메뉴를 살펴 보면, 대부분의 경우 사용할 수 없는 회색으로 표시된다.
//Preferences 메뉴도 없는데, iOS 앱에서 Settings을 추가하면, macOS 앱에 Preferences로 추가된다.
//이를 위해 Settings Bundle을 추가한다. 새 파일에서 iOS ▸ Resource ▸ Settings Bundle
//그러면 프로젝트에 Settings.bundle이 추가된다. 이를 열고 작업해 준다.
//해당 부분을 수정해 줬으면 앱에서 사용할 수 있도록, UserDefaults에 해당 키를 설정해 줘야 한다.
//해당 조건에 맞춰 코드를 추가해 준다.

//Creating a MacOS BullsEye app
//Catalyst 프레임워크로 iOS 개발자가 macOS 용 앱을 쉽게 만들 수 있다.
//이전 세션에서 만든 패키지를 사용해 macOS 앱을 작성한다.
//새로운 macOS 프로젝트를 생성한다. macOS ▸ App을 선택하고, SwiftUI User Interface를 선택한다.
//ContetView.swift를 작성할 필요없이 이전에 작성한 GameView package를 import해 가져오면 된다.
//그리고, app target의 Frameworks, Libraries and Embedded Content 세션에서
//해당 GameView 패키지를 추가해 주면된다.
//AppDelegate에서 GameView의 ContetnView를 찾을 수 있도록 import 해준다.

//Creating a tvOS BullsEye app
//tvOS도 비슷한 방법으로 만들면 된다. 하지만, tvOS에는 Slider가 없다. 이를 다른 방식으로 구현해야 한다.
//새로운 tvOS 프로젝트를 생성한다. tvOS ▸ Single View App을 선택하고,
//SwiftUI User Interface를 선택한다. Game 패키지를 가져오고,
//app target의 Frameworks, Libraries and Embedded Content 세션에서 Game패키지를 추가해 준다.
//Slider 대신 TextField에서 값을 입력 받아 표시해 주는 것으로 변경한다.

//Using the tvOS simulator
//시뮬레이터를 Keyboard Connected 메시지가 뜬다.
//키보드의 위, 아래 버튼을 눌러 초점을 이동한다.
//Hardware 메뉴에서 Show Apple TV Remote(Shift-Command- R)를 눌러 리모컨을 사용해도 된다.



