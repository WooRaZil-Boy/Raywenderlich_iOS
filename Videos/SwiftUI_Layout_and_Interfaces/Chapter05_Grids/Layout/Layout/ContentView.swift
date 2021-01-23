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
  var body: some View {
//    LazyVGrid(
//      columns: [
////        .init(), //default는 .flexible 모든 columns이 같은 width를 가진다.
//        //size, spacing, alignment가 모두 기본설정으로 생성된다.
//        .init(.fixed(50), spacing: 30),
//        //지정된 값을 줄 수도 있다.
//        .init(.flexible(minimum: 200), spacing: 30),
//        //flexible도 값을 지정해 줄 수 있다.
//        .init(.adaptive(minimum: 30), spacing: 30)
//        //adaptive를 사용하면 제약조건을 알아서 맞추기 때문에, 다중 columns을 지정해 줄 필요가 없다.
//      ]
      
    ScrollView(.horizontal) {
      LazyHGrid(
        rows: [
  //        .init(), //default는 .flexible 모든 columns이 같은 width를 가진다.
          //size, spacing, alignment가 모두 기본설정으로 생성된다.
          .init(.fixed(300), spacing: 30),
          //지정된 값을 줄 수도 있다.
          .init(.flexible(maximum: 200), spacing: 30),
          //flexible도 값을 지정해 줄 수 있다.
          .init(.adaptive(minimum: 30), spacing: 30)
          //adaptive를 사용하면 제약조건을 알아서 맞추기 때문에, 다중 columns을 지정해 줄 필요가 없다.
        ]
        //LazyHGrid를 사용하면, 대신 rows을 사용한다.
      ) {
        //Stack는 방향에 따라 HStack, VStack, lazy 여부에 따라 LazyStack, Stack으로 구분할 수 있다.
        //Grid 또한 Stack과 비슷하게 LazyVGrid, LazyHGrid가 있다.
        ForEach(
//          Genre.list.randomElement()!.subgenres.shuffled().prefix(20),
          Genre.list.randomElement()!.subgenres,
          content: \.view
        )
      }
      .padding(.horizontal)
    }
  }
}

private extension Genre.Subgenre {
  var view: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(
        LinearGradient(
          gradient: .init(
            colors: AnyIterator { } .prefix(2).map {
              .random(saturation: 2 / 3, value: 0.85)
            }
          ),
          startPoint: .topLeading, endPoint: .bottomTrailing
        )
      )
//      .frame(height: 125) //VGrid
      .frame(width: 125) //HGrid
      .overlay(
        Image("Genre/\(Int.random(in: 1...92))")
          .resizable()
          .saturation(0)
          .blendMode(.multiply)
          .scaledToFit()
      )
      .overlay(
        Text(name)
          .foregroundColor(.white)
          .fontWeight(.bold)
          .padding(10)
          .frame(alignment: .bottomLeading),
        alignment: .bottomLeading
      )
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
