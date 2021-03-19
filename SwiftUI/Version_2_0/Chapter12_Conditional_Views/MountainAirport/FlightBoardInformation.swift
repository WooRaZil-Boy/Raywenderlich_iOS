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

struct CheckInInfo: Identifiable {
  let id = UUID()
  let airline: String
  let flight: String
}

struct FlightBoardInformation: View {
  var flight: FlightInformation
  @Binding var showModal: Bool
  @State private var rebookAlert: Bool = false
  @State private var checkInFlight: CheckInInfo?
  @State private var showFlightHistory = false
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack{
        Text("\(flight.airline) Flight \(flight.number)")
          .font(.largeTitle)
        Spacer()
        Button("Done", action: {
          self.showModal = false
        })
      }
      Text("\(flight.direction == .arrival ? "From: " : "To: ")" +
        "\(flight.otherAirport)")
      Text(flight.flightStatus)
        .foregroundColor(Color(flight.timelineColor))
      
      if flight.isRebookAvailable() {
        //해당 view는 flight의 상태가 .cancelled인 경우에만 표시된다.
        Button("Rebook Flight", action: {
          self.rebookAlert = true
          //button을 tap하면, rebookAlert가 true로 설정된다.
        })
        .alert(isPresented: $rebookAlert) {
          //Button 구조체에서 alert(isPresented:content:)를 call 하여 Alert을 생성한다.
          //또한 rebookAlert가 true가 되면 alert을 표시하도록 상태 변수를 전달한다.
          Alert(title: Text("Contact Your Airline"),
                message: Text("We cannot rebook this flight." +
                  "Please contact the airline to reschedule this flight."))
          //enclosure에서 Alert 구조체로 user에게 표시할 메시지를 정의한다.
          //추가적인 button은 제공하지 않으므로, user의 유일한 option은 OK 버튼을 tap하여 alert을 해제하는 것이다.
        }
      }
      
      if flight.isCheckInAvailable() {
        //check-in이 가능한 flight에 대해서만 button을 표시한다.
        Button("Check In for Flight", action: {
          self.checkInFlight = CheckInInfo(airline: self.flight.airline, flight: self.flight.number)
          //button의 action은 checkInMessage 상태 변수를
          //airline와 flight로 저장하는 새로운 CheckInMessage 인스턴스를 설정한다.
        })
        .actionSheet(item: $checkInFlight) { flight in
          //alert과 마찬가지로, button에 action sheet를 추가한다.
          //actionSheet(isPresented:content:)가 아닌 actionSheet(item:content:)를 사용하여
          //optional variable를 item: 매개변수에 전달하며, non-nil일 때 actionSheet를 표시한다.
          //non-nil 변수는 이전에 작성한 alert의 bool과 같이 trigger 역할을 한다.
          //또한 enclosure 내부에 매개변수를 제공한다.
          //SwiftUI가 sheet를 표시할 때, 이 매개변수는 trigger를 바인딩하여 내용을 표시한다.
          ActionSheet(
            title: Text("Check In"),
            message: Text("Check in for \(flight.airline)" +
                      "Flight \(flight.flight)"),
            //전달된 변수의 내용을 사용하여 action sheet를 생성한다.
            buttons: [
              //alert의 제한적인 feedback에 비해, action sheet는 더 많은 option을 제공하지만, 모두 Button이어야 한다.
              //사용하려는 item을 ActionSheet.Button의 array로 하여 buttons: 매개변수에 전달한다.
              .cancel(Text("Not Now")),
              //처음으로 정의된 button은 .cancel이다.
              //cancel button은 user에게 명확한 back-out option을 제공한다.
              //user가 이 option을 선택하면 아무런 작업도 수행되지 않으며, Text 이외의 매개변수가 필요하지 않다.
              .destructive(Text("Reschedule"), action: {
                print("Reschedule flight.")
                //debug console에 메시지 출력
              }),
              //.destructive는 파괴적이거나 위험한 결과를 초래하는 작업에 대해 사용한다.
              //SwiftUI는 이 action의 심각성을 강조하기 위해 빨간색 text를 사용한다.
              //action: 으로 제공하는 코드는 user가 이 option을 선택할때 실행된다.
              .default(Text("Check In"), action: {
                print("Check-in for \(flight.airline) \(flight.flight).")
              })
              //.default는 action: 에 지정된 debug console에 메시지 출력을 실행한다.
          ])
        }
      }
      Button("On-Time History") {
        self.showFlightHistory.toggle()
      }
      .popover(isPresented: $showFlightHistory, arrowEdge: .top) {
        FlightTimeHistory(flight: self.flight)
      }

      Spacer()
    }
    .font(.headline)
    .padding(10)
  }
}

struct FlightBoardInformation_Previews: PreviewProvider {
  static var previews: some View {
    FlightBoardInformation(flight: FlightInformation.generateFlight(0),
                           showModal: .constant(true))

  }
}




