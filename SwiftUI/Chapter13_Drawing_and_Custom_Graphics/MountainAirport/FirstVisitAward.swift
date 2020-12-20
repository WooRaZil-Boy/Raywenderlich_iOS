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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct FirstVisitAward: View {
    var body: some View {
//        Rectangle()
////          .fill(Color.blue)
//          .fill(
//            LinearGradient(gradient: .init(colors: [Color.green, Color.blue]),
//                           startPoint: .bottomLeading,
//                           endPoint: .topTrailing
//          ))
//          .frame(width: 200, height: 200)
      
//      ZStack {
//        //3개의 squares를 담을 ZStack을 정의한다. ZStack은 내용을 overlay하여 양쪽 축에 정렬한다.
//        //여기서는 squares이 겹겹이 겹쳐 보이게 될 것이다.
//        ForEach(0..<3) { i in //3번 반복한다.
//          //i 로 loop의 값을 가져온다.
//          Rectangle()
//            .fill(
//              LinearGradient(gradient: .init(colors: [Color.green, Color.blue]),
//                             startPoint: .bottomLeading,
//                             endPoint: .topTrailing)
//          )
//          //Rectangle은 이전 코드와 같다.
////          .frame(width: 200, height: 200)
//          //reactive하게 구현하려면 frame이 고정되지 않는 것이 좋다.
//          .rotationEffect(.degrees(Double(i) * 60.0))
//          //각도에 대해 .degrees를 사용하여 각도를 지정해 shape에 회전을 적용한다.
//          //loop시 마다 회전 각도가 60도 씩 증가한다.
//          //사각형에 대한 fill, frame, rotation은 순서대로 적용된다.
//        }
//        Image(systemName: "airplane")
//          .resizable()
//          .rotationEffect(.degrees(-90))
//          .opacity(0.5)
//      }
      
      GeometryReader { geometry in
        //GeometryReader 컨테이너는 view의 size와 shape을 가져올 수 있다.
        //따라서 상수에 의존하지 않고 코드를 작성할 수 있다.
        ZStack {
          ForEach(0..<3) { i in
            Rectangle()
              .fill(
                LinearGradient(
                  gradient: .init(colors: [Color.green, Color.blue]),
                  startPoint: .bottomLeading,
                  endPoint: .topTrailing)
                )
            .frame(width: geometry.size.width * 0.7,
                   height: geometry.size.width * 0.7)
            .rotationEffect(.degrees(Double(i) * 60.0))
            //geometry의 size 속성을 사용하여 view의 width와 height를 가져온다.
            //각각에 0.7를 곱하여, squares가 회전한 후에도 frame에 맞도록 한다.
            //trigonometry으로 이 scaling factor를 계산하거나, 원하는 shape가 될 때까지 값을 바꿔가며 시도한다.
            //SwiftUI preview의 장점은 compile–run loop 없이 즉시 변경하고 결과를 볼 수 있다는 것이다.
            //이렇게 하면, 원하는 결과를 얻을 때까지 값을 쉽게 조정할 수 있다.
          }
          Image(systemName: "airplane")
            .resizable().rotationEffect(.degrees(-90))
            .opacity(0.5)
            .scaleEffect(0.7)
            //squares 크기만큼 이미지의 배율도 조정한다. .scaleEffect() 를 호출하여 이를 수행한다.
        }
      }
    }
}

struct FirstVisitAward_Previews: PreviewProvider {
    static var previews: some View {
//        FirstVisitAward()
//          .environment(\.colorScheme, .dark)
      //버그로 preview에 dark mode가 적용되지 않는다.
      
//      Group {
//        FirstVisitAward()
//          .environment(\.colorScheme, .light)
//
//        NavigationView {
//          FirstVisitAward()
//        }
//        .environment(\.colorScheme, .dark)
//      }
      
      Group {
        FirstVisitAward()
          .environment(\.colorScheme, .light)
          .frame(width: 200, height: 200)
        
        FirstVisitAward()
          .environment(\.colorScheme, .dark)
          .frame(width: 200, height: 200)
      }
    }
}
