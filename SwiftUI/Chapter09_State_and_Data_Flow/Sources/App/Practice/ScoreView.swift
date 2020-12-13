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

//class Box<T> {
//  var wrappedValue: T
//  init(initialValue value: T) { self.wrappedValue = value }
//}
//wrapping class를 사용할 수도 있지만 좀 더 SwiftUI 틱한 방법으로 구현할 수 있다.

struct ScoreView: View {
//  var numberOfQuestions = 5
//  @State var numberOfQuestions: Int
  //동적인 값이 아니므로, @State나 var로 선언할 필요가 없다.
  let numberOfQuestions: Int

  
//  struct State { //구조체로 선언하면, immutable이기 때문에 값을 변경할 수 없다.
//    //class로 변경하면 컴파일이 정상적으로 되지만, SwiftUI에서는 @State를 사용할 수 있다.
////    var numberOfAnswered = 0
//    //numberOfAnswered를 구조체로 Encapsulate한다.
////    var numberOfAnswered = Box<Int>(initialValue: 0)
//  }
  
//  var state = State()
  //해당 구조체의 인스턴스를 새 property로 추가한다.
  
//  var _numberOfAnswered = State<Int>(initialValue: 0) //State 사용
  
//  @State var numberOfAnswered = 0 //@State로 전달하면 값이 복사되기 때문에
  @Binding var numberOfAnswered: Int //@Binding으로 참조로 선언해준다.
//  @State var numberOfAnswered = 0



    var body: some View {
//      Button(action: { //Button을 추가한다.
////        self.state.numberOfAnswered += 1 //구조체는 immutable이기 때문에 오류
//        //action handler에서는 numberOfAnswered를 증가시킨다.
////        print("Answered: \(self.state.numberOfAnswered)")
////        self.state.numberOfAnswered.wrappedValue += 1 //wrapping class의 속성 업데이트
////        print("Answered: \(self.state.numberOfAnswered.wrappedValue)")
////        self._numberOfAnswered.wrappedValue += 1
//        //button의 action handler에서 counter를 증가시킨다.
////        print("Answered: \(self._numberOfAnswered.wrappedValue)")
//        //button의 action handler에서 counter를 출력한다.
//
//        self.numberOfAnswered += 1
//        print("Answered: \(self.numberOfAnswered)")
//        //@State를 사용하면 선언한 변수명을 그대로 사용할 수 있다.
//      }) { //Button의 body에 이전에 구현한 content를 포함한다.
        
      HStack {
//          Text("\(state.numberOfAnswered)/\(numberOfQuestions)")
//          Text("\(state.numberOfAnswered.wrappedValue)/\(numberOfQuestions)")
//          Text("\(_numberOfAnswered.wrappedValue)/\(numberOfQuestions)")
            //button의 embedded view에서 총 질문에 대한 답변 수를 표시한다.
          
          Text("\(numberOfAnswered)/\(numberOfQuestions)")
            //@State를 사용하면 선언한 변수명을 그대로 사용할 수 있다.
            .font(.caption)
            .padding(4)
//          Text("ScoreView Counter: \(numberOfAnswered)")

          
          Spacer()
        }
      
      
      
//      }
    }
}

struct ScoreView_Previews: PreviewProvider {
  @State static var numberOfAnswers: Int = 0
  //새 state property를 생성한다.
  
    static var previews: some View {
        ScoreView(
          numberOfQuestions: 5,
          numberOfAnswered: $numberOfAnswers
      )
      //새 property를 ScoreView의 생성자에 전달한다.
      
//      ScoreView(numberOfQuestions: 5)
    }
}
