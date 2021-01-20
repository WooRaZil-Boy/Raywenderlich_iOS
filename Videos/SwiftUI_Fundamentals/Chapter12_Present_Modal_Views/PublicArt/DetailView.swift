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

struct DetailView: View {
  let artwork: Artwork
  @State private var showMap = false
  
  var body: some View {
    VStack {
      Text(artwork.title)
        .font(.title2)
        .multilineTextAlignment(.center)
        .lineLimit(3)
      
      Button(action: { showMap = true }) { //Button을 누르면, showMap이 true가 되고,
        HStack(alignment: .firstTextBaseline) {
          Image(systemName: "mappin.and.ellipse")
          
          Text(artwork.locationName)
            .font(.headline)
        }
      }
//        .sheet(isPresented: $showMap) { //showMap이 toggle되면서 sheet가 호출된다.
          //showMap는 dismiss될 때 자동으로 toggle된다.
          //이런 형식의 구현은 .alert, .popover 등에서도 동일하게 사용된다.
        .fullScreenCover(isPresented: $showMap) {
          //fullScreenCover를 사용하면, fullScrenn으로 sheet가 호출된다.
          //다만 swipe로 dismiss할 수 없으므로, 따로 해당 로직을 구현해 줘야 한다.
          //여기서는 LocationMap의 Button을 추가하여 탭할 때 bool 값을 변경해 준다.
          LocationMap(artwork: artwork, showModal: $showMap)
        }
        //NavigationView와 NavigationLink를 사용하는 것 외에도, .sheet를 사용하여 View를 이동할 수 있다.
        //.sheet는 다음과 같은 특징이 있다.
        // - static dependencies을 추가하면, dependency injection이 강제된다.
        // - bindable Bool을 toggle한다.
        // - swipe해서 dimiss한다.
      
      Text("Artist: \(artwork.artist)")
        .font(.subheadline)
      
      Image(artwork.imageName)
        .resizable()
        .frame(maxWidth: 300, maxHeight: 600)
        .aspectRatio(contentMode: .fit)
      
      Divider()
      
      Text(artwork.description)
        .multilineTextAlignment(.leading)
        .lineLimit(20)
    }
    .padding()
    .navigationBarTitleDisplayMode(.inline)

  }
}

struct DetailView_Previews: PreviewProvider {
  static var previews: some View {
    DetailView(artwork: artData[0])
  }
}

