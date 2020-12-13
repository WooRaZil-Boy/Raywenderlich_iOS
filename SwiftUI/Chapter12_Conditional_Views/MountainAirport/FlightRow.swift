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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct FlightRow: View {
  var flight: FlightInformation
  @State private var isPresented = false
  
  var body: some View {
//    HStack {
//      Text("\(self.flight.airline) \(self.flight.number)")
//        .frame(width: 120, alignment: .leading)
//      Text(self.flight.otherAirport)
//        .frame(alignment: .leading)
//      Spacer()
//      Text(self.flight.flightStatus)
//        .frame(alignment: .trailing)
//    }
    
    Button(action: { //버튼 동작은 toggle
      self.isPresented.toggle()
    }) {
      HStack { //버튼 내부 row에 대한 HStack 래핑
        Text("\(self.flight.airline) \(self.flight.number)")
          .frame(width: 120, alignment: .leading)
        Text(self.flight.otherAirport)
          .frame(alignment: .leading)
        Spacer()
        Text(self.flight.flightStatus)
          .frame(alignment: .trailing)
      }
      .sheet(isPresented: $isPresented, onDismiss: {
        //sheet(isPresented:onDismiss:content:)를 사용해 modal을 표시한다.
        //변수가 true가 될 때, modal을 표시하도록 isPresented 상태 변수를 전달한다.
        //사용자가 modal을 닫으면, SwiftUI는 state를 다시 false로 설정한다.
        print("Modal dismissed. State now: \(self.isPresented)")
        //onDismiss: 클로저에는 사용자가 modal을 해제한 이후 실행할 코드가 포함된다.
        //여기서는 console에 message를 출력하고 state value가 false임을 보여준다.
      }) {
        FlightBoardInformation(flight: self.flight,
                               showModal: self.$isPresented)
        //sheet(isPresented:onDismiss:content:)의 클로저로 modal sheet에 표시할 view를 제공한다.
      }
    }
  }
}

struct FlightRow_Previews: PreviewProvider {
  static var previews: some View {
    FlightRow(flight: FlightInformation.generateFlight(0))
  }
}



