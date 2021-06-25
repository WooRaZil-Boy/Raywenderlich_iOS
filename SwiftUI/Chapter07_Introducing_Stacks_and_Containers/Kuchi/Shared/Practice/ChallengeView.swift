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
  @State var showAnswers = false
  
  var body: some View {
    //    Text("A great and warm welcome to Kuchi")
    //모든 뷰는 기본적으로 상위 항목의 중앙에 배치된다.
    //    Image("welcome-background")
    //      .resizable() // 기본 해상도
    //      .background(Color.red)
    //Text의 내용에 맞춰 frame이 조정된다.
    //      .frame(width: 150, height: 50, alignment: .center)
    //      .frame(width: 300, height: 100, alignment: .center)
    //      .frame(width: 100, height: 50, alignment: .center)
    //      .minimumScaleFactor(0.5)
    //      .background(Color.yellow)
    // 1. 프레임 뷰(frame view)의 고정 크기(fixed size)는 150x50 포인트(points)이다.
    // 2. 프레임 뷰(frame view)는 그 크기(size)를 Text에 제안(proposes)한다.
    // 3. Text는 해당 크기(size) 내에서 텍스트(text)를 표시하는 방법을 찾지만, 가능한(possible) 경우 자르지(truncate) 않고 최소값(minimum)을 사용한다.
    
    //    HStack {
    //      Text("A great and warm welcome to Kuchi")
    //        .background(Color.red)
    //      Text("A great and warn welcome to Kuchi")
    //        // <- Replace `m` with `n` in `warm`
    //        .background(Color.red)
    //    }
    //    .background(Color.yellow)
    // 1. 스택(stack)은 부모(parent)로부터 제안된 크기(proposed size)를 받아, 두 개의 동일한(equal) 부분으로 나눈다.
    // 2. 스택(stack)은 자식(children) 중 하나에게 첫 번째 크기(size)를 제안(proposes)한다. 그들은 동등(equal)하기 때문에, 첫 번째 자식(child)인 왼쪽 뷰에게 먼저 제안(proposal)한다.
    // 3. Text는 두 줄(two lines)로 텍스트(text)를 표시(display)할 수 있고, 두 줄이 비슷한 길이(lengths)를 갖도록 서식(format)을 지정할 수 있기 때문에 제안된 크기(proposed size)보다 필요한 크기가 더 작다.
    // 4. 스택(stack)은 첫 번째 Text가 차지하는 크기(size)를 빼고(subtracts), 결과 크기(resulting size)를 두 번째 Text에 제안(proposes)한다.
    // 5. Text는 제안된 크기(proposed size)를 모두 사용하기로 결정(decides)한다.
    
    //    HStack {
    //      Text("A great and warm welcome to Kuchi")
    //        .layoutPriority(-1)
    //        //우선 순위를 지정해 줄 수 있다.
    //        .background(Color.red)
    //      Text("A great and warm welcome to Kuchi")
    //        .layoutPriority(1)
    //        //우선 순위를 지정해 줄 수 있다.
    //        .background(Color.red)
    //      Text("A great and warm welcome to Kuchi")
    //        .background(Color.red)
    //    }
    //    .background(Color.yellow)
    
    //    HStack(alignment: .bottom) {
    //    HStack(alignment: .firstTextBaseline) {
    //        Text("Welcome to Kuchi").font(.caption)
    //        Text("Welcome to Kuchi").font(.title)
    //        Button(action: {}, label: { Text("OK").font(.body) })
    //      }
    
    
    
    
    VStack { //두 개의 뷰가 수직으로 쌓이기 때문에 VStack을 사용한다.
      Button(action: { //QuestionView를 감싸고, ChoicesView의 hidden을 toggle한다.
        self.showAnswers.toggle()
      }) {
        QuestionView(question: challengeTest.challenge.question)
          .frame(height: 300)
        //자체 파일로 구현되는 QuestionView
      }
      
      if showAnswers { //showAnswers이 참일 때만 ChoiceView를 표시한다.
        Divider()
        
        ChoicesView(challengeTest: challengeTest)
          .frame(height: 300)
          .padding()
        //자체 파일로 구현된 ChoiceView로 ChallengeTest를 매개변수로 사용한다.
      }
    }
  }
}


struct ChallengeView_Previews: PreviewProvider {
  static let challengeTest = ChallengeTest(
    challenge: Challenge(
      question: "おねがい　します",
      pronunciation: "Onegai shimasu",
      answer: "Please"
    ),
    answers: ["Thank you", "Hello", "Goodbye"]
  )
  //미리보기에서 사용할 ChallengeTest를 생성한다.
  
  static var previews: some View {
    return ChallengeView(challengeTest: challengeTest)
    //해당 Test를 뷰 생성자에 전달한다.
  }
}

//Layout and priorities
// SwiftUI가 상위 뷰(parent view)와 하위 뷰(child view)의 크기(size)를 결정(determine)하기 위해 적용(applies to)하는 규칙(rules)은 다음과 같다
// 1. 상위 뷰(parent view)는 사용 가능한(available) 프레임(frame)을 결정(determines)한다.
// 2. 상위 뷰(parent view)는 하위 뷰(child view)에 크기(size)를 제안(proposes)한다.
// 3. 상위 뷰(parent)의 제안(proposal)에 따라, 하위 뷰(child view)는 크기(size)를 선택한다.
// 4. 상위 뷰(parent view)는 하위 뷰(child view)를 포함(contains)하도록 자체적인 크기(sizes)를 조정한다.
