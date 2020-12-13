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

struct ChallengeView: View {
  let challengeTest: ChallengeTest
//  @ObservedObject var challengesViewModel = ChallengesViewModel()
  
  @State var showAnswers = false
  
//  @State var numberOfAnswered = 0
  @Binding var numberOfAnswered: Int
  
  @Environment(\.verticalSizeClass) var verticalSizeClass
  //기기 방향 환경 변수
  
  @Environment(\.questionsPerSession) var questionsPerSession
  //세션 당 문제 수 환경 변수


//  var body: some View {
//    VStack {
//      Button(action: {
//        self.showAnswers = !self.showAnswers
////        self.numberOfAnswered += 1
////        self.challengesViewModel.generateRandomChallenge()
//        //generateRandomChallenge()는 새로운 무작위 challenge를 선택하여 currentChallenge에 넣는다.
//      }) {
//        QuestionView(question: challengeTest.challenge.question)
////        QuestionView(question:
////          challengesViewModel.currentChallenge!.challenge.question)
//          .frame(height: 300)
//      }
//
//      // -Insert this-
//      ScoreView(numberOfQuestions: 5,
//                numberOfAnswered: $numberOfAnswered)
////      ScoreView(numberOfQuestions: 5)
////      Text("ChallengeView Counter: \(numberOfAnswered)")
//
//      if showAnswers {
//        Divider()
//        ChoicesView(challengeTest: challengeTest)
////          ChoicesView(
////            challengeTest: challengesViewModel.currentChallenge!)
//          .frame(height: 300)
//          .padding()
//      }
//    }
//  }
  
  @ViewBuilder
  //body는 잠재적으로 여러 view를 반환할 수 있으므로 @ViewBuilder가 필요하다.
  var body: some View {
    if verticalSizeClass == .compact {
      //vertical class가 .compact 인지 확인한다. true이면 가로 모드
      VStack {
        //landscape //VStack을 사용하여 하단에 ScoreView를 표시한다.
        HStack {
          //HStack은 QuestionView와 ChoicesView를 배치한다.
          Button(action: {
            self.showAnswers = !self.showAnswers
          }) {
            QuestionView(question: challengeTest.challenge.question)
          }
          if showAnswers {
            Divider()
            ChoicesView(challengeTest: challengeTest)
          }
        }
        ScoreView(numberOfQuestions: questionsPerSession,
                  numberOfAnswered: $numberOfAnswered)
      }
    } else {
      //portrait //이전의 구현
      VStack {
        Button(action: {
          self.showAnswers = !self.showAnswers
        }) {
          QuestionView(question: challengeTest.challenge.question)
            .frame(height:300)
        }
        ScoreView(numberOfQuestions: questionsPerSession,
                  numberOfAnswered: $numberOfAnswered)
        if showAnswers {
          Divider()
          ChoicesView(challengeTest: challengeTest)
            .frame(height:300)
            .padding()
        }
      }
    }
  }
}


struct ChallengeView_Previews: PreviewProvider {
  @State static var numberOfAnswered: Int = 0
  
    static let challengeTest = ChallengeTest(
      challenge: Challenge(question: "おねがい　します", pronunciation: "Onegai shimasu", answer: "Please"),
      answers: ["Thank you", "Hello", "Goodbye"]
    )

    static var previews: some View {
//      return ChallengeView(challengeTest: challengeTest)
      
      return ChallengeView(challengeTest: challengeTest,
                           numberOfAnswered: $numberOfAnswered)
    }
}
