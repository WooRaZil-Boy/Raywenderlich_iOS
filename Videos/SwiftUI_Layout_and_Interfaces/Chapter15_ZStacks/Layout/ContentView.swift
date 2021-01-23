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
  let gradient = LinearGradient(
    gradient: Gradient(
      stops: [
        .init(color: .brightSeafoam, location: CGFloat(3.0 / 8.0)),
        .init(color: .darkSeafoam, location: 1)
      ]
    ),
    startPoint: .topTrailing, endPoint: .bottom
  )
  var body: some View {
    ZStack(alignment: .center) { //ZStack은 첫 번째 item이 가장 뒤에 위치하면서, 하나씩 앞으로 쌓는다.
      //ZStack은 alignment은 9개의 options이 있다.
      Image("RWStack")
        .resizable()
        .scaledToFit()
//        .overlay(gradient)
//        .blendMode(.multiply) //겹쳐질 때의 mode를 선택한다.
      
      gradient //LinearGradient도 하나의 View이다.
        .blendMode(.multiply)
        .layoutPriority(-1) //parent가 해당 layout의 공간을 설정할 우선 순위를 결정한다.
        //default는 0이다.

      VStack(alignment: .trailing) {
        Image("ZStack")
          .resizable()
          .scaledToFit()
          .frame(width: 80)

        Text("Stacks to the Max!")
          .fontWeight(.semibold)
          .foregroundColor(.brightSeafoam)
      }
//        .padding()
        .alignmentGuide(HorizontalAlignment.center) { $0[.trailing] }
        .alignmentGuide(VerticalAlignment.center) { $0[.top] }
        //ZStack은 horizontalAlignment와 VerticalAlignment를 모두 사용할 수 있다.
    }
  }
}

extension Color {
  static let brightSeafoam = Color("Bright Seafoam")
  static let darkSeafoam = Color("Dark Seafoam")
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
