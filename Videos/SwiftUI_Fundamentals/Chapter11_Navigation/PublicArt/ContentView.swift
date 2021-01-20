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
  @State var artworks = artData
  
  var body: some View {
    //Navigation을 구현하기 위해서는 NavigationView와 NavigationLink를 사용한다.
    NavigationView { //새로운 Navigation Stack의 Root가 된다.
      List(artworks) { artwork in
        NavigationLink(
          destination: DetailView(artwork: artwork),
          //해당 NavigationLink를 눌렀을 때 연결할 destination View
          label: {
            Text(artwork.title)
          })
        //NavigationLink는 다음과 같은 특징이 있다.
        // - content를 wrapping 한다.
        // - content를 tappable 하게 한다.
        // - 손쉽게 destination을 제공한다.
        // - tap state가 내장되어 자동으로 업데이트된다.
      }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Artworks")
        //NavigationView가 아닌 내부 View에 navigationBarTitle modifier를 사용해야 한다.
      
      DetailView(artwork: artworks[0])
      //iPad에서는 SplitView가 default 이기 때문에, iPhone과 다르게 List가 aside에 숨겨져 있고 빈 화면이 나타난다.
      //이 때 처음 DetailView가 보여지도록 설정해 준다. iPhone에서는 List가 꽉 차기 때문에 해당 옵션이 보이지 않는다.
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
