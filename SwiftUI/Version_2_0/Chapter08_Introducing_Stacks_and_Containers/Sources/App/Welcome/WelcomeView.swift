/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct WelcomeView: View {
  @EnvironmentObject var userManager: UserManager
  @ObservedObject var challengesViewModel = ChallengesViewModel()
  @State var showPractice = false

  @ViewBuilder
  //body에는 if-else 쌍이 포함되어 있으므로, 컴파일러를 만족시키려면 @ViewBuilder이 있어야 한다.
  //이전에 StarterView에서 했던 것과 동일하다.
  var body: some View {
    if showPractice { //showPractice가 참이면 PracticeView를 표시한다.
      PracticeView(
        challengeTest: $challengesViewModel.currentChallenge,
        userName: $userManager.profile.name
      )
    } else { //그렇지 않으면, welcome message를 표시한다.
      ZStack {
        WelcomeBackgroundImage()
        
        VStack {
          Text(verbatim: "Hi, \(userManager.profile.name)")
          
          WelcomeMessageView()
          
          Button(action: {
            self.showPractice = true
          }, label: {
            HStack {
              Image(systemName: "play")
              Text(verbatim: "Start")
            }
          })
          //이 버튼을 누르면 showPractice를 설정하여, welcome message를 확인하고
          //practice를 시작할 때 사용한다.
        }
      }
    }
  }
}

struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView()
      .environmentObject(UserManager())
  }
}
