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

struct FlightBoard: View {
  var boardName: String
  var flightData: [FlightInformation]
  
  @State private var hideCancelled = false
  var shownFlights: [FlightInformation] {
    hideCancelled ?
      flightData.filter { $0.status != .cancelled } :
      flightData
  }

  var body: some View {
//    Text(boardName)
//      .font(.title)
    
//    VStack {
//      Text(boardName)
//        .font(.title)
////      ForEach(flightData, id: \.id) { flight in
//      ForEach(flightData) { flight in
//        //FlightInformation이 id를 준수하므로 따로 지정해 줄 필요가 없다.
//        Text("\(flight.airline) \(flight.number)")
//      }
//    }
    
//    VStack {
//      Text(boardName)
//        .font(.title)
//      ScrollView([.horizontal, .vertical]) {
//        ForEach(flightData) { flight in
//          VStack {
//            Text("\(flight.airline) \(flight.number)")
//            Text("\(flight.flightStatus) at \(flight.currentTimeString)")
//            Text("At gate \(flight.gate)")
//          }
//        }
//      }
//    }
    
//    VStack {
//      Text(boardName)
//        .font(.title)
//      NavigationView {
//        List(flightData) { flight in
//          Text("\(flight.airline) \(flight.number)")
//        }
//      }
//    }
    
//    VStack {
////      Text(boardName)
////        .font(.title)
//      List(flightData) { flight in
////        Text("\(flight.airline) \(flight.number)")
//        FlightRow(flight: flight)
//      }
//      .navigationBarTitle(boardName)
//    }
    
//    List(flightData) { flight in
    List(shownFlights) { flight in
      NavigationLink(destination: FlightBoardInformation(flight: flight)) {
        FlightRow(flight: flight)
      }
    }
    .navigationBarTitle(boardName)
    .navigationBarItems(trailing:
      Toggle(isOn: $hideCancelled, label: {
        Text("Hide Cancelled")
      })
    )
  }
}

struct FlightBoard_Previews: PreviewProvider {
  static var previews: some View {
    FlightBoard(boardName: "Test",
                flightData: FlightInformation.generateFlights())
  }
}
