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
//    ScrollView {
////      LazyVStack {
//      LazyVStack(pinnedViews: [.sectionHeaders, .sectionFooters]) {
//        //Stack이나 Grid를 사용하는 경우, pinnedViews를 사용할 수 있다.
//        //option으로는 .sectionHeaders와 sectionFooters가 있다.
//        //해당 option을 사용하면, Section이 pinned된다.
//        //아직은 pure SwiftUI 코드로 작성할 수 있는 방법이 없다.
    
    ScrollView(.horizontal) {
//      LazyHStack(pinnedViews: [.sectionHeaders, .sectionFooters]) { //HStack에서도 설정할 수도 있다.
      LazyHGrid( //Stack 뿐 아니라, Grid에서도 사용할 수 있다.
        rows: .init(repeating: .init(), count: 6),
        pinnedViews: [.sectionHeaders, .sectionFooters]
      ) {
        ForEach(Genre.list) { genre in
          Section(
            header: genre.header,
            footer: genre.header
          ) {
            //Section을 추가해 Header를 지정해 줄 수 있다.
//            ForEach(genre.subgenres.prefix(5)) {
            ForEach(genre.subgenres) {
              $0.view.frame(width: 125)
            }
          }
        }
      }
    }
  }
}

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
