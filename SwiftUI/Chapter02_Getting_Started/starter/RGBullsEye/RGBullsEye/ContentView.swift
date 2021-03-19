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
  @State var game = Game()
  @State var guess: RGB
  var target = RGB.random()
  
  @State var showScore = false

  var body: some View {
    VStack {
//      Color(red: 0.5, green: 0.5, blue: 0.5)
//      Color(rgbStruct: game.target)
      Circle()
        .fill(Color(rgbStruct: game.target))
      if !showScore {
        //Command-click 이후 Make Conditional 선택해 if-else를 추가한다.
        Text("R: ??? G: ??? B: ???")
          //직접 입력할 수 있지만, Library에서 가져와 editor나 canvas 어디에나 drag-and-drop해서 추가할 수 있다.
          //Control-Option-click 으로 inspector를 열어 modifier를 추가할 수 있다.
          .padding()
      } else {
        Text(game.target.intString())
          .padding()
      }
//      Color(red: 0.5, green: 0.5, blue: 0.5)
//      Color(rgbStruct: guess)
      //guess.red 자체는 단지 읽기 전용(read-only)인 값(value)이다. $guess.red는 읽기-쓰기(read-write) 바인딩(binding)이다.
      Circle()
        .fill(Color(rgbStruct: guess))
//      Text("R: 204 G: 76 B: 178")
//      Text(
//        "R: \(Int(guess.red * 255.0))"
//          + "  G: \(Int(guess.green * 255.0))"
//          + "  B: \(Int(guess.blue * 255.0))")
      Text(guess.intString())
        .padding()
      ColorSlider(value: $guess.red, trackColor: .red)
      ColorSlider(value: $guess.green, trackColor: .green)
      ColorSlider(value: $guess.blue, trackColor: .blue)
      Button("Hit Me!") {
        showScore = true
        game.check(guess: guess)
      }
      .alert(isPresented: $showScore) {
        //UIButton처럼 Button의 action 으로 alert을 추가하는 것이 아니라, modifier로 추가하고 state에 따라 출력되도록 한다.
        Alert(
          title: Text("Your Score"),
          message: Text(String(game.scoreRound)),
          dismissButton: .default(Text("OK")) {
            game.startNewRound()
            guess = RGB()
          })
      }
    }
  }
}

struct ColorSlider: View {
  //Command-click 이후 Extract Subview로 추출할 수 있다.
  @Binding var value: Double
  var trackColor: Color

  var body: some View {
    HStack {
      Text("0")
      Slider(value: $value)
        .accentColor(trackColor)
      Text("255")
    }
    .padding(.horizontal)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(guess: RGB())
  }
}

//canvas 새로고침 : Option-Command-P
//Option-Command-[ , Option-Command-] 으로 코드를 한 줄씩 옮길 수 있다.
