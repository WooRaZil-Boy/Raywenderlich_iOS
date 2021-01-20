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
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES  OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      HStack(alignment: .bottom, spacing: 20.0) {
        Thumbnail()
        VStack {
          //중복되거나 재사용되는 부분을 계속해서 subview로 만들어 준다.
          MixDescription()
          Buttons()
        }
      }
        .padding()
        .frame(minHeight: 150, maxHeight: 250) //필요한 값만 줄 수 있다.
      Spacer()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Image("meowMix")
      .resizable()
      .frame(maxHeight: 250)
      .previewLayout(.sizeThatFits)
    
    Thumbnail()
      .padding()
      .previewLayout(.fixed(width: 250, height: 250))

    ContentView()
  }
}

struct Thumbnail: View {
  var body: some View {
    ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
      ZStack {
        RoundedRectangle(cornerRadius: 12)
          .foregroundColor(.accentColor)
          .aspectRatio(1, contentMode: .fit) //1:1 비율로 정사각형이 되도록 한다.
          .shadow(radius: 10)
        
        Image(systemName: "play.fill")
          .resizable()
          .frame(width: 50, height: 50)
          .foregroundColor(.white)
          .opacity(0.4)
      }
      VStack(alignment: .leading) {
        Text("Meow!")
          .font(.largeTitle)
          .fontWeight(.black)
        Text("Mix")
          .font(.largeTitle)
        Spacer()
      }
      .foregroundColor(.white)
      .padding()
    }
  }
}

struct ButtonLabel: View {
  //⌘ + Click 후, Extract subview를 사용해 쉽게 처리할 수 있다.
  let title: String
  let systemImage: String
  
  var body: some View {
    HStack {
      Spacer()
      Label(title, systemImage: systemImage)
      Spacer()
      //Spcaer를 사용해서 가운데 정렬을 한다.
    }
    .padding(.vertical)
    .background(Color.gray.opacity(0.15))
    .cornerRadius(12)
  }
}

struct Buttons: View {
  var body: some View {
    HStack(spacing: 12.0) {
      Button { print("Play!") }
        label: {
          ButtonLabel(title: "Play!", systemImage: "play.fill")
        }
      Button { print("Suffle!") }
        label: {
          ButtonLabel(title: "Suffle!", systemImage: "suffle")
        }
    }
  }
}

struct MixDescription: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 20.0) {
      VStack(alignment: .leading) { //따로 alignment을 지정하지 않는다면 축에 대한 .center로 지정된다.
        Text("Meow! Mix")
          .font(.title)
          .fontWeight(.semibold)
        Text("Apple Music for Ozma")
          .font(.title)
          .fontWeight(.light)
          .foregroundColor(.accentColor)
        Text("Updated Caturday")
          .font(Font.system(.body).smallCaps())
      }
      Text("Whether you're a kitten or an old-timer, get meowing with this purrsonalized mix of music to meow to!")
      //padding을 줘서 20만큼 간격을 띄울 수도 있지만, Stack의 spacing을 사용할 수도 있다.
    }
  }
}
