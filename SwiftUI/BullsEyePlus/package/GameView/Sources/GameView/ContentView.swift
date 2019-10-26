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

public struct ContentView: View {
  @ObservedObject private var game = BullsEyeGame()

  @State private var currentValue = 50.0
  @State private var showAlert = false

  private var alpha: Double {
    abs(Double(game.targetValue) - currentValue) / 100.0
  }

  public var body: some View {
    VStack {
      Text("Put the Bull's Eye as close as you can to: \(game.targetValue)")
      HStack {
        Text("0")
        Slider(value: $currentValue, in: 1.0...100.0, step: 1.0)
          .background(Color.blue)
          .opacity(alpha)
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
    
    public init() { }
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
