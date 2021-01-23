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
  @State private var selectedGenre = Genre.list.first

  var body: some View {
    NavigationView {
      ScrollView { //pinnedViews를 제대로 사용하려면 ScrollView를 추가한다.
        ScrollViewReader { scrollProxy in
          LazyVStack(pinnedViews: .sectionHeaders) {
            //일반 VStack은 pinnedViews를 지원하지 않는다.
            ForEach(Genre.list) { genre in
              Section(header: genre.header.id(genre)) {
                LazyVGrid(
                  columns: [.init(.adaptive(minimum: 150))]
                ) {
                  ForEach(genre.subgenres, content: \.view)
                  //key-value mapping으로 ForEach에서 view를 가져올 수 있다.
                }
                .padding(.horizontal)
              }
            }
          }
          .onChange(of: selectedGenre) { genre in
            scrollProxy.scrollTo(selectedGenre, anchor: .top)
            selectedGenre = nil
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Menu("Genre") {
            ForEach(Genre.list) { genre in
              Button(genre.name) {
                selectedGenre = genre
              }
            }
          }
        }
      }
    }
  }
}

//현재 Xcode 최신 버전에서는 Genre에서 멀리 있는 것을 선택하면, 정확한 위치로 스크롤이 되지 않는 버그가 있다.

private extension Genre {
  var header: some SwiftUI.View {
    HStack {
      Text(name)
        .font(.title2)
        .fontWeight(.bold)
        .padding(.leading)
        .padding(.vertical, 8)

      Spacer()
    }
    .background(UIBlurEffect.View(blurStyle: .systemThinMaterial))
    .frame(maxWidth: .infinity)
  }
}

//⌘ + ⇧ + L 로, Library를 열어 View와 Modifier를 끌어와 추가할 수 있다.

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
      .frame(height: 125)
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
