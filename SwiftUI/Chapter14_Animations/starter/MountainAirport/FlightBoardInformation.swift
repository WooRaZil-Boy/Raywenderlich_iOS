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
  
  extension AnyTransition {
    static var flightDetailsTransition: AnyTransition {
//      AnyTransition.slide
      
      let insertion = AnyTransition.move(edge: .trailing)
        .combined(with: .opacity)
      let removal = AnyTransition.scale(scale: 0.0)
        .combined(with: .opacity)
      return .asymmetric(insertion: insertion, removal: removal)
    }
  }
  
  struct CheckInInfo : Identifiable {
    let id = UUID()
    let airline: String
    let flight: String
  }
  
  struct FlightBoardInformation: View {
    var flight: FlightInformation
    @Binding var showModal: Bool
    @State private var showDetails = false
    var flightDetailAnimation : Animation {
      Animation.easeInOut
    }
    
    var body: some View {
      VStack(alignment: .leading) {
        HStack{
          Text("\(flight.airline) Flight \(flight.number)")
            .font(.largeTitle)
          Spacer()
          Button("Done", action: {
            self.showModal = false })
        }
        Text("\(flight.direction == .arrival ? "From: " : "To: ") \(flight.otherAirport)")
        Text(flight.flightStatus)
          .foregroundColor(Color(flight.timelineColor))
        FlightConditionals(flight: self.flight)
        Button(action: {
//          withAnimation(.default) { //view가 아닌 point에도 animation을 추가할 수 있다.
//          withAnimation(self.flightDetailAnimation) { //사용자 정의 animation
//            self.showDetails.toggle()
//          }
          
          withAnimation {
            self.showDetails.toggle()
          }
        }) {
          HStack {
//            if showDetails {
//              Text("Hide Details")
//              Spacer()
//              Image(systemName: "chevron.up.square")
//            } else {
//              Text("Show Details")
//              Spacer()
//              Image(systemName: "chevron.down.square")
//            }
            
            Text(showDetails ? "Hide Details" : "Show Details")
            Spacer()
            Image(systemName: "chevron.up.square")
              .scaleEffect(showDetails ? 2 : 1)
//              .animation(nil) //animation이 동기화 되지 않고 즉시 실행된다.
//              .animation(.spring(response: 0.55, dampingFraction: 0.45,
//                                 blendDuration: 0))
              .rotationEffect(.degrees(showDetails ? 0 : 180))
              .animation(flightDetailAnimation)

//              .animation(.easeInOut)
          }
        }
        if showDetails {
          FlightDetails(flight: flight)
//            .offset(x: showDetails ? 0 : -UIScreen.main.bounds.width)
//            .animation(.default)
//            .animation(.easeOut)
//            .animation(.easeOut(duration: 2))
//            .animation(.interpolatingSpring(mass: 1, stiffness: 100,
//                                          damping: 10, initialVelocity: 0))
//            .animation(.spring(response: 0.55, dampingFraction: 0.45,
//                               blendDuration: 0))
//            .animation(Animation.spring().delay(1))
//            .animation(Animation.spring().speed(2))
//            .animation(Animation.spring()
//                        .repeatCount(2, autoreverses: false))
//            .animation(.spring())
//            .transition(.slide)
//            .transition(.move(edge: .bottom))
            .transition(.flightDetailsTransition)
        }
        Spacer()
      }.font(.headline).padding(10)
    }
  }
  
  struct FlightBoardInformation_Previews: PreviewProvider {
    static var previews: some View {
      FlightBoardInformation(flight:
        FlightInformation.generateFlight(0),
                             showModal: .constant(true))
    }
  }
