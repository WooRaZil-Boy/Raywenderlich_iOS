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

struct MovieList: View {
  @StateObject var movieStore = MovieStore()
  //지금까지 @State에 사용한 변수 타입은 struct, enum, 일반 변수 들로 모두 value type이었다.
  //하지만, MovieStore는 class로 reference type이다.
  //이럴 때, @StateObject를 쓸 수 있으며, MovieStore의 선언을 살펴보면 ObservableObject인 것을 알 수 있다.
  //https://jaesung0o0.medium.com/swiftui-data-flow-stateobject-vs-observedobject-e32a37d80dd2
  @State private var isPresented = false

  var body: some View {
    NavigationView {
      List {
        ForEach(movieStore.movies, id: \.title) {
          MovieRow(movie: $0)
        }
        .onDelete(perform: movieStore.deleteMovie)
      }
      .sheet(isPresented: $isPresented) {
        AddMovie(movieStore: movieStore, showModal: $isPresented)
      }
      .navigationBarTitle(Text("Fave Flicks"))
      .navigationBarItems(
        leading:
          NavigationLink(destination: UserView()) {
            HStack {
              Image(systemName: "person.fill")
            }
          },
        trailing:
          Button(action: { isPresented.toggle() }) {
            Image(systemName: "plus")
          }
      )
    }
  }
}

//@State
// - Holds data
// - Passes copies

//@Binding
// - References data
// - Passes a reference

//----

//@State
// - Value Types

//@StateObject
// - Refernce Types

struct MovieList_Previews: PreviewProvider {
  static var previews: some View {
    MovieList(movieStore: MovieStore())
  }
}
