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
    let isCompleting: Bool

    var body: some View {
      Capsule()
        .stroke(isCurrent ? Color.white : .gray, lineWidth: 8)
        .frame(width: 20, height: isCompleting ? 20 : 50)
        .offset(
          isCurrent
            ? .init(width: 10, height: 0)
            : .init(width: 40, height: 70)
        )
        .scaleEffect(isCurrent ? 0.5 : 1)
        .rotationEffect(isCompleting ? .zero : rotation)
        //isCompleting가 true이면, 기본값으로 회전시켜 모든 Leaf가 모여진다.
        .animation(.easeIn(duration: 1.5))
    }
  }

  let leavesCount = 12
  @State var currentIndex = -1
  @State var completed = false
  //애니메이션을 종료시킬 타이밍을 알려주기 위한 변수를 선언한다.
  @State var isVisible = true
  //애니메이션이 종료되면서 사라지도록 하기 위한 변수를 선언한다.
  
  let shootUp = AnyTransition.offset(x: 0, y: -1000)
    .animation(.easeIn(duration: 1))
  //Transition에는 opacity, slide, move(edge), offset, scale 이 있다.
  
  var body: some View {
    VStack {
      if isVisible {
        ZStack {
          ForEach(0..<leavesCount) { index in
            Leaf(
              rotation: .init(degrees: .init(index) / .init(leavesCount) * 360),
              isCurrent: index == currentIndex,
              isCompleting: completed
            )
          }
        }
        .transition(shootUp)
        .onAppear(perform: animate)
      }
    }
  }
  
  func animate() {
    var iteration = 0
    
    Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
      currentIndex = (currentIndex + 1) % leavesCount
      
      iteration += 1
      if iteration == 30 { //30번 반복 후
        timer.invalidate() //timer를 종료 시키고,
        completed = true //애니메이션 종료 변수의 값을 변경한다.
        currentIndex = -1
        //이를 설정하지 않으면, timer가 종료될 때에도 마지막 leaf는 생성되어 애니메이션을 하므로 하나가 맞지 않는 것 처럼 보이게 된다.
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
          isVisible = false
        }
      }
    }
  }
}

//state의 변경으로 애니메이션을 적용하도록 구현한다.

struct SpinnerView_Previews : PreviewProvider {
  static var previews: some View {
    SpinnerView()
  }
}
