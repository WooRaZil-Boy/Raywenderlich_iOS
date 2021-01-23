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
    ScrollView(.horizontal) {
      LazyVStack {
        //일반 VStack을 사용하여 결과를 확인해 보면, Date가 모두 같음을 알 수 있다.
        //이는 한 번에 모든 item을 생성하기 때문이며, 이 상태에서는 state가 업데이트되어 re-render할 때에 큰 비용이 든다.
        //Lazy Stack은 iOS14에서 부터 사용할 수 있으며, 화면의 보이는 부분만을 표시한다.
        //해당 화면이 필요할 때 render하므로, Date도 달라지는 것을 확인할 수 있다.
        //Lazu Stack을 사용하면 대량의 collection 데이터에 대해 쉽고 빠르게 성능을 향상 시킬 수 있다.
//      List {
        //List는 기본적으로 hybrid lazy loading을 구현하고 있다.
        //하지만, 정렬의 위치가 다르고 Date가 모두 같은 것을 확인할 수 있다.
        //List는 Swipe-to-delte, Reordering 등의 메서드와
        //구분선, 네비게이션 바 등의 Built-in 스타일이 구현되어 있는 특별한 버전의 Lazy VStack이다.
        let formatter: DateFormatter = {
          let formatter = DateFormatter()
          formatter.timeStyle = .medium
          return formatter
        } ()
        
        ForEach(Genre.list.flatMap(\.subgenres)) { subgenre in
          //Lazy Stack을 사용하면, 전체를 불러와도 보이는 부분만 가져오기 때문에 훨씬 부하가 줄어든다.
//        ForEach(Genre.list.prefix(2).flatMap(\.subgenres)) { subgenre in
          //Genre.list.flatMap(\.subgenres)로 사용하면, 전체 list를 가져오기 때문에 preview에서 과부하가 걸린다.
          Text(
            formatter.string(from: Date())
          )
          subgenre.view
        }
      }
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
      .frame(width: 125, height: 125)
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
