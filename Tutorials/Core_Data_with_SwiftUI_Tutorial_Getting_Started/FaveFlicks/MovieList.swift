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

// swiftlint:disable multiple_closures_with_trailing_closure
struct MovieList: View {
//  @State var movies = MovieList.makeMovieDefaults()
//  @State var movies: [Movie] = []
  @FetchRequest(
    //@FetchRequest 속성 래퍼를 사용하여 속성을 선언하면, SwiftUI 뷰에서 결과를 직접 사용할 수 있다.
    entity: Movie.entity(),
    //속성 래퍼 내에서 가져올 Core Data 엔티티를 지정한다.
    //여기서는 Movie 엔티티의 instances를 fetch한다.
    sortDescriptors: [
      //결과의 순서를 결정하기 위해, sort descriptors 배열을 추가한다.
      //예를 들어, genre별로 영화를 정렬한 다음 같은 genre의 영화에 대해서는 title별로 정렬할 수 있다.
      NSSortDescriptor(keyPath: \Movie.title, ascending: true)
      //여기서는 단순하게 title로 정렬한다.
    ]
//    predicate: NSPredicate(format: "genre contains 'Action'")
    //추가 조건
  ) var movies: FetchedResults<Movie>
  //마지막으로, property wrapper 다음에 FetchedResults 유형의 movies 속성을 선언한다.
  @Environment(\.managedObjectContext) var managedObjectContext

  @State var isPresented = false

  var body: some View {
    NavigationView {
      List {
        ForEach(movies, id: \.title) {
          MovieRow(movie: $0)
        }
        .onDelete(perform: deleteMovie)
      }
      .sheet(isPresented: $isPresented) {
        AddMovie { title, genre, release in
          self.addMovie(title: title, genre: genre, releaseDate: release)
          self.isPresented = false
        }
      }
      .navigationBarTitle(Text("Fave Flicks"))
        .navigationBarItems(trailing:
          Button(action: { self.isPresented.toggle() }) {
            Image(systemName: "plus")
          }
      )
    }
  }

  func deleteMovie(at offsets: IndexSet) {
//    movies.remove(atOffsets: offsets)
    //Core Data로 대체한다.
    
    offsets.forEach { index in
      //SwiftUI의 List는 목록에서 객체를 삭제하기 위해 swipe할 때, 삭제할 IndexSet를 제공한다.
      //forEach를 사용하여 IndexSet을 반복한다.
      let movie = self.movies[index]
      //현재 index에 대한 movie를 가져온다.
      self.managedObjectContext.delete(movie)
      //managed object context에서 movie를 삭제한다.
    }
    saveContext()
    //context를 저장하여, 변경사항을 디스크에 유지한다.
  }

  func addMovie(title: String, genre: String, releaseDate: Date) {
//    let newMovie = Movie(title: title, genre: genre, releaseDate: releaseDate)
//    movies.append(newMovie)
    //Core Data로 대체한다.
    
    let newMovie = Movie(context: managedObjectContext)
    //managed object context에서 새로운 Movie를 생성한다.
    
    newMovie.title = title
    newMovie.genre = genre
    newMovie.releaseDate = releaseDate
    //addMovie(title:genre:releaseDate:)로 전달된 매개변수를 Movie의 모든 속성에 설정한다.
    
    saveContext()
    //managed object context를 저장한다.
  }

//  static func makeMovieDefaults() -> [Movie] {
//    let theRoom = Movie(
//      title: "The Room",
//      genre: "Drama",
//      releaseDate: Date(timeIntervalSince1970: 1056730041))
//    let sharknado = Movie(
//      title: "Sharknado",
//      genre: "Action, Adventure",
//      releaseDate: Date(timeIntervalSince1970: 1373558841))
//    let kungPow = Movie(
//      title: "Kung Pow: Enter the Fist",
//      genre: "Action, Comedy",
//      releaseDate: Date(timeIntervalSince1970: 1011974841))
//
//    return [theRoom, sharknado, kungPow]
//  }
  //더 이상 사용되지 않으므로 삭제한다.
  
  func saveContext() {
    do {
      try managedObjectContext.save()
    } catch {
      print("Error saving managed object context: \(error)")
    }
  }
}

struct MovieList_Previews: PreviewProvider {
  static var previews: some View {
    MovieList()
  }
}
