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
  var body: some View {
    GeometryReader { proxy in
      //GeometryReader를 사용하면, % 단위로 크기를 설정해 줄 수 있다.
      //GeometryReader는 View로 어떤 것도 render하지 않지만, size를 제공해 준다.
      HStack {
        //Stack을 사용할 때, 특정 View가 굉장히 커지거나 혹은 작아지는 경우가 발생할 수 있다.
        Image("Cake VStack")
          .resizable()
          .scaledToFit()
//          .frame(width: 250.0)
          //hard coding frame은 화면 크기와 설정에 따라 문제가 발생할 수 있다.
          .frame(width: proxy.size.width * 0.5)
        Text("Reading is dreaming with open eyes.")
          .layoutPriority(1)
        Image("Pancake VStack")
          .resizable()
          .scaledToFit()
      }
    }
//      .frame(width: 250.0)
    //Stack의 크기를 고정하면 첫 Image만 보여지게 되는 문제가 발생한다.
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View { ContentView() }
}
