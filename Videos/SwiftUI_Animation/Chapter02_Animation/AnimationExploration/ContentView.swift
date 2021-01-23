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

struct ContentView: View {
  //View protocol은 body를 구현해야 한다.
  private struct AnimationData {
    let offset: CGSize
    var color: Color

    static let array: [Self]  = [
      .init(
        offset: .init(width: 0, height: 0),
        color: .green
      ),
      .init(
        offset: .init(width: 100, height: 0),
        color: .blue
      ),
      .init(
        offset: .init(width: 100, height: -100),
        color: .red
      ),
      .init(
        offset: .init(width: -100, height: -100),
        color: .orange
      ),
      .init(
        offset: .init(width: -100, height: 0),
        color: .yellow
      )
    ]
  }
  
  @State private var animationData = AnimationData.array[0]
  //data model을 변경할 때마다, SwiftUI는 최신 변경 사항을 각 View의 현재 body에 적용한다.
  //SwiftUI는 계속해서 View를 snapshot하고, state가 바뀔 때 이를 업데이트한다.
  
  //@State 속성은 View가 수정될 때마다 새로운 snapshot을 trigger한다.
  //UI를 업데이트 해야한다면 view를 직접적으로 수정하는 것이 아니라, @State 속성을 변경하여 새로운 UI를 자동으로 re-render하도록 trigger한다.

  var body: some View {
    Circle()
      .scaleEffect(0.5)
//      .foregroundColor(.green)
      .foregroundColor(animationData.color)
      //색상을 변경하면, SwiftUI는 새로운 snapshot을 생성한다.
      .offset(animationData.offset) //위치를 이동 시킨다.
      .padding()
      .animation(.default) //애니메이션을 추가해 색상이 부드럽게 변경되도록 한다.
      //.default는 .35 duration에 .easeInOut timing을 사용한다.
      .onAppear {
        for (index, data) in AnimationData.array.enumerated().dropFirst() {
          //첫 번째 색상은 이미 지정되어 있으므로 drop한 후, 반복한다.
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(index)) {
            //UI업데이트는 main thread에서 실행되어야 한다.
            animationData = data
          }
        }
      }
  }
}

//Animation은 시간에 따른 value 또는 state의 변화로 정의할 수 있으며,
//start value + end value + durations 로 이루어져 있다고 생각할 수 있다.

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
