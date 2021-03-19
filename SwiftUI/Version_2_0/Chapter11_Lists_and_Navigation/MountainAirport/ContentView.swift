/// Copyright (c) 2019 Razeware LLC
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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ContentView: View {
  var flightInfo: [FlightInformation] = FlightInformation.generateFlights()
  
  var body: some View {
//    NavigationView {
//      HStack {
//        ZStack {
//          Image(systemName: "airplane")
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 250, height: 250, alignment: .center)
//            .opacity(0.1)
//            .rotationEffect(.degrees(-90))
//          Spacer()
//        }
//      }
//      .navigationBarTitle(Text("Mountain Airport"))
//    }
    
//    TabView {
//      //TabView를 선언한다.
//      FlightBoard(boardName: "Arrivals")
//        //view의 집합을 제공한다.
//        //각 view는 Tap의 내용이 되고, view의 modifiers는 각 tap에 대한 정보를 정의한다.
//        .tabItem({
//          //tabItem(_:)를 각 view의 content에 적용하여 각 tab에 대해 Image, Text를 조합한다.
//          Image(systemName: "icloud.and.arrow.down")
//            .resizable()
//          Text("Arrivals")
//          //각 tab에는 system image와 text label이 표시된다.
//          //Text, Image, Text가 포함된 Image 만을 tab의 label로 사용할 수 있다.
//          //다른 요소를 사용하면, tab이 표시되지만 비어 있는 것으로 표시된다.
//        })
//      FlightBoard(boardName: "Departures")
//        .tabItem({
//          Image(systemName: "icloud.and.arrow.up")
//            .resizable()
//          Text("Departures")
//        })
//    }
    
    NavigationView {
      //navigation hierarchy의 path를 나타내는 view stack의 시작점을 정의한다.
      //일반적으로 master-detail flow이 있는 데이터를 처리할 때 이것을 사용한다.
      //여기에서는 user가 선택할 수 있는 항목의 목록을 보여주는 두 개의 비행 옵션이다.
      //navigation view는 또한 toolbar와 이러한 view에서 뒤로 갈 수 있는 link도 제공한다.
      ZStack {
        Image(systemName: "airplane")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .opacity(0.1)
          .rotationEffect(.degrees(-90))
          .frame(width: 250, height: 250, alignment: .center)
        VStack(alignment: .leading, spacing: 5) {
//          NavigationLink(destination: FlightBoard(
//            //NavigationLink 구조체는 user가 navigation stack 안으로 더 깊이 이동할 수 있는 button을 만든다.
//            //destination: 매개변수는 user가 view stack의 다음 step으로 이동하기 위한 button을 누를 때, 표시할 view를 제공한다.
//            boardName: "Arrivals")) {
//              Text("Arrivals")
//              //NavigationLink의 enclosure는 link로 표시되는 view가 된다.
//              //여기에서는 static Text를 사용한다.
//            }
//          NavigationLink(destination: FlightBoard(
//            boardName: "Departures")) {
//              Text("Departures")
//            }
          
          NavigationLink(destination: FlightBoard(
            boardName: "Arrivals",
            flightData: self.flightInfo.arrivals())) {
              Text("Arrivals")
            }
          NavigationLink(destination: FlightBoard(
            boardName: "Departures",
            flightData: self.flightInfo.departures())) {
              Text("Departures")
            }
          Spacer()
        }
        .font(.title)
        .padding(20)
      }
      .navigationBarTitle(Text("Mountain Airport"))
      //상단에 표시할 NavigationView의 title을 지정한다.
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}







