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
//    VStack(alignment: .center) {
    VStack(alignment: .customCenter) {
      //AlignmentID를 구현하여, custom alignment를 사용할 수 있다.
      HStack {
        ScaledImage("Trig")
        ScaledImage("Patterns")
        Text("Learn SwiftUI layout!")
          .alignmentGuide(.customCenter) { $0[.leading] }
          //alignmentGuide에서도 custom alignment를 사용할 수 있다.
      }
      //AlignmentID protocol

      HStack {
        Text("Help others learn it too!")
          .alignmentGuide(.customCenter) { $0[.trailing] }
        ScaledImage("Hearts")
      }

      HStack {
        ScaledImage("Rocket")
        Text("Then let's all make some awesome apps!")
          .multilineTextAlignment(.center)
        ScaledImage("Party")
      }
    }
      .frame(width: 250, height: 250)
  }
}

//leading, center, trailing
//top, center, bottom
//First Text, Baseline, Alignment
//Last Text, Baseline, Alignment

extension HorizontalAlignment {
  enum CustomCenter: AlignmentID { //어떤 type이든 AlignmentID를 구현할 수 있지만, case없는 enum이 가장 간단하다.
    //AlignmentID를 사용해 custom하고 재사용가능한 alignment를 만들 수 있다.
    //Stack 내부에 있는 특정 Views의 guides를 정렬하고자 할 때 유용하게 사용할 수 있다.
    static func defaultValue(in context: ViewDimensions) -> CGFloat {
      //AlignmentID는 해당 메서드를 필수로 구현해야 한다.
      context[HorizontalAlignment.center]
      //custom alignment의 default value를 지정한다.
    }
  }
  
  static let customCenter = Self(CustomCenter.self)
}
 
struct ScaledImage: View {
  let name: String

  init(_ name: String) {
    self.name = name
  }

  var body: some View {
    Image(name)
      .resizable()
      .scaledToFit()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View { ContentView() }
}
