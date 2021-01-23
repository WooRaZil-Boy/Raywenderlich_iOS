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
//    VStack(spacing: -100.0) {
      //spacing 값이 매우 크다면 화면을 벗어날 수 있고, - 라면 겹쳐질 수 있다.
//    VStack(alignment: .leading) { //VStack은 HorizontalAlignment을 지정한다.
      //alignment의 default는 .center이다.
    HStack(alignment: .lastTextBaseline) { //HStack은 VerticalAlignment을 지정한다.
      //alignment의 default는 .center이다.
      //HStack은 Attributes Inspector에서 나타나지 않는 .firstTextBaseline .lastTextBaseline 옵션이 있다.
      //.firstTextBaseline는 다른 View를 Text의 첫 줄과 맞춘다.
      //.lastTextBaseline는 다른 View를 Text의 마지막 줄과 맞춘다.
      Image("Cake VStack")
      //⇧ + ⌘ + L 로 Library의 Media 탭에서 해당 이미지를 가져올 수도 있다.
        .resizable()
        .scaledToFit()
      Text("Hello, \nLayout\n!")
//        .multilineTextAlignment(.leading)
        //multilineTextAlignment는 default가 .leading이다.
      Image("Pancake VStack")
        .resizable()
        .frame(width: 100.0, height: 100.0)
//        .scaledToFit()
    }
  }
}

//⌘ + ⌥ + return 으로 canvas를 열고 닫을 수 있다.
//⌘ + ⌥ + P 로 preview를 referesh할 수 있다.
//⇧ + ⌘ + L 로 Library를 열 수 있다.
//⌃ + ⌥ + Click 하여 Attributes Inspector를 pop-up할 수 있다(canvas에서도 가능하다).
//canvas에서 해당 control을 ⌘ + click하여도 Embed in ... 을 선택할 수 있다.

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
