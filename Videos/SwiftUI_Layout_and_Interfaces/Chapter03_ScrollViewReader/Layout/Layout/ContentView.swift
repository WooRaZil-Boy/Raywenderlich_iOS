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
  //선택한 Genre
  
  var body: some View {
    NavigationView {
      //⌘ + click을 사용해 어떤 Embed in ...를 선택하고, View를 바꿔주면 된다.
      ScrollView {
        ScrollViewReader { proxy in
          //ScrollViewReader를 사용하면, proxy로 ScrollView의 특정 지점까지 이동하도록
          //프로그래밍 방식으로 제어할 수 있다.
          //ScrollViewReader는 ScrollView를 포함할 수 있지만, 보통은 ScrollView에 포함되도록 구현한다.
          LazyVStack {
            ForEach(Genre.list) { genre in
              genre.subgenres.randomElement()!.view
                .id(genre)
               //Identifiable를 구현한 객체를 id로 지정해 준다.
               //반대로 target을 지정해 주는 .anchor 메서드도 존재한다.
            }
            .onChange(of: selectedGenre) { genre in
              //selectedGenre가 변경되면, 해당 code block이 실행된다.
              selectedGenre = nil
              //이미 선택한 genre를 다시 선택하는 경우에 움직이지 않으므로 해당 코드를 추가해 준다.
              withAnimation { //애니메이션과 함께 스크롤된다.
//                proxy.scrollTo(genre, anchor: .top)
                //ScrollViewReader의 proxy를 사용하여 스크롤한다.
                //스크롤 대상 id로 지정하며, Hashable을 구현해야 한다.
                proxy.scrollTo(genre)
                //위치를 숫자 값으로 제어하는 대신, 특정 View의 특정 지점으로 스크롤한다.
              }
            }
          }
        }
      }
      //NavigationView가 아닌 NavigationView의 내부에 설정해야 한다.
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Menu("Genre") {
            //작업할 Menu를 보여준다.
            ForEach(Genre.list) { genre in
              Button(genre.name) {
                selectedGenre = genre
                //Button을 선택하면, selectedGenre를 해당 genre로 지정해 준다.
              }
            }
          }
        }
      }
    }
  }
}

//⌘ + ⇧ + L 로, Library를 열어 Modifier를 끌어와 추가할 수 있다.

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
