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

struct SpinnerView: View {
  struct Leaf: View {
    let rotation: Angle
    let isCurrent: Bool
    
    var body: some View {
      Capsule()
        .stroke(isCurrent ? Color.white : .gray, lineWidth: 8)
        .frame(width: 20, height: 50)
//        .offset(x: 0, y: 70)
        .offset(
          isCurrent
            ? .init(width: 10, height: 0)
            : .init(width: 40, height: 70)
        )
        .scaleEffect(isCurrent ? 0.5 : 1)
        .rotationEffect(rotation) //회전
        .animation(.easeIn(duration: 1.5)) //애니메이션을 추가해 부드럽게 전환되도록 한다.
    }
  }
  
  let leavesCount = 12
  @State var currentIndex = -1
  
  var body: some View {
    VStack {
      ZStack {
        ForEach(0..<leavesCount) { index in
          //⌘ + click 하여 Repeat을 선택하면, ForEach를 쉽게 생성할 수 있다.
          Leaf(
            rotation: .init(degrees: .init(index) / .init(leavesCount) * 360),
            isCurrent: index == currentIndex
          )
        }
      }
      .onAppear(perform: animate)
      //View가 나타나면 해당 method를 실행한다.
    }
  }
  
  func animate() {
    Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
      currentIndex = (currentIndex + 1) % leavesCount
    }
  }
}

struct SpinnerView_Previews : PreviewProvider {
  static var previews: some View {
    SpinnerView()
  }
}
