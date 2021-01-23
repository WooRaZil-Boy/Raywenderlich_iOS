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
    let cornerRadius: CGFloat = 7.5 //재사용 위해 상수를 설정해 준다.
    
    HStack(alignment: .top) {
      VStack {
        Image("RW")
          .resizable()
          .frame(width: 90, height: 90)
          .cornerRadius(cornerRadius)
          .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
              .stroke(Color.white, lineWidth: 2.5)
          )
        
        Text("Following")
          .font(.body)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .padding(.horizontal, 10) //.horizontal을 선택하면, .leading과 .trailing에 padding이 추가된다.
          .padding(.vertical, 4) //.vertical을 선택하면, .top과 .bottom에 padding이 추가된다.
          .background(Color.blue)
          .clipShape(Capsule())
      }

      VStack(alignment: .leading) {
        Text("raywenderlich.com")
          .font(.headline)
          .foregroundColor(.white)
        HStack(alignment: .lastTextBaseline) {
          Text("@rwenderlich")
            .font(.subheadline)
            .foregroundColor(.white)
          Text("FOLLOWS YOU")
            .font(.caption)
            .foregroundColor(.init(white: 0.4))
            .padding(.horizontal, 10)
            .background(Color(white: 0.9)) //여기서는 View가 유형이므로, Color를 명시해 줘야 한다.
            .clipShape(Capsule())
        }
        Text(
          "We are a friendly and supportive community of mobile developers. "
            + "We love to learn and share our knowledge with the world! "
            + "raywenderlich.com"
        )
          .padding(.top, 5)
          .lineSpacing(-.infinity)
      }
    }
  }
}

//⌃ + ⌥ + Click 하여 Attributes Inspector를 pop-up할 수 있다(canvas에서도 가능하다).
//Attributes Inspector에서 아래쪽의 Add Modifier를 선택하여, 필요한 Modifier를 추가해 줄 수도 있다.

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ZStack {
      Color(red: 0.55, green: 0.45, blue: 0.75)
      ContentView()
    }
      .edgesIgnoringSafeArea(.all)
  }
}
