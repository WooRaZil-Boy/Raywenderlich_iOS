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

struct ContentView: View {
  @State private var swiftyColor: Color = .red
  @State private var swiftyOpacity: Double = 0.7
  //@State 속성은 state를 개별적으로 메모리에 자동 저장한다.
  //state가 변경되게 되면, dependent Views의 re-render를 triggers한다.

  var body: some View {
    VStack {
      SwiftyControls(swiftyColor: $swiftyColor,
                     swiftyOpacity: $swiftyOpacity)
      //⌘ + Click 후, Extract subview를 사용해 쉽게 처리할 수 있다.
      Image(systemName: "swift")
        .resizable()
        .scaledToFit()
        .padding(25)
        .foregroundColor(.white)
        .opacity(swiftyOpacity)
        .background(swiftyColor)
        .cornerRadius(50)
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

struct SwiftyControls: View {
  @Binding var swiftyColor: Color
  @Binding var swiftyOpacity: Double
  //Single source of truth를 준수하기 위해서는 @State가 아닌 @Binding으로 사용해야 한다.
  
  var body: some View {
    VStack {
      ColorPicker("Swifty Color", selection: $swiftyColor)
      Slider(value: $swiftyOpacity, in: 0...1)
        .accentColor(swiftyColor)
      //일부 구성 요소는 initializer에서 binding을 사용한다.
      //value가 아닌 binding에 대한 reference를 전달할 때, $를 사용한다.
      //Binding 타입에 .constant를 사용하여 preview를 작성하는 것은 좋지만, 실제 value와 연동하려면 binding해야 한다.
    }
  }
}
