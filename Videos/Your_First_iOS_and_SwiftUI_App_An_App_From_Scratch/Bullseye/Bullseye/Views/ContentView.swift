//
//  ContentView.swift
//  Bullseye
//
//  Created by youngho on 2021/01/15.
//

import SwiftUI

struct ContentView: View {
  @State private var alertIsVisible = false
  //상태 변수. 값이 변함에 따라 자동으로 업데이트한다.
  //SwiftUI에서 View는 struct이므로 일반적으로 내부의 값을 바꿀 수 없다. 따라서 @State를 사용하여 값을 변화시킬 수 있는 변수를 지정해 준다.
  @State private var sliderValue = 50.0
  @State private var game = Game()
  
  var body: some View {
    VStack {
      Text("🎯🎯🎯\nPUT THE BULLSEYE AS CLOSE AS YOU CAN TO")
        .bold()
        .kerning(2.0) //글자 사이 간격. return이 Text 이므로 다른 modifier와 반환형이 맞는지 확인해야 한다.
        .multilineTextAlignment(.center)
        .lineSpacing(4.0)
        .font(.footnote) //HIG에 따라, fixed 값 대신 이미 지정되어진 값을 넣어주는 것이 좋다.
      Text(String(game.target))
        .kerning(-1.0)
        .font(.largeTitle)
        .fontWeight(.black)
      HStack {
        Text("1")
          .bold()
        Slider(value: $sliderValue, in: 1.0...100.0)
        //.constant는 고정 값을 binding한다.
        Text("100")
          .bold()
      }
      Button(action: {
        print("Hello, SwiftUI")
        alertIsVisible = true
      }) {
        Text("Hit me")
      }
      .alert(isPresented: $alertIsVisible, content: {
        //dimiss되면, isPresented 값이 자동으로 false로 변경된다.
        let roundedValue = Int(sliderValue.rounded())
        //Int로 바로 형변환하면, 반올림이 아닌 버림이 되어 버린다.
        return Alert(title: Text("Hello there!"),
                     message: Text("The slider's value is \(roundedValue).\n" + "You scored \(game.points(sliderValue: roundedValue)) points ths round."),
                     dismissButton: .default(Text("Awesome!")))
        //$를 사용하여 binding한다. //view와 state를 연결한다.
      })
    }
  }
}

//⌃ + i 로 블록의 indent를 정렬할 수 있다.
//⌥ + ⌘ + [ or ] 로 해당 행의 코드를 한 줄씩 replace할 수 있다.
//StoryBoard와 같이 Library에서 View와 Modifier를 끌어와 추가해 줄 수 있다.
//canvas, code 양쪽 어느 부분이든 drag-drop 하면 된다.
//⌥ + ⌘ + p 로 preview를 새로고침한다.

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
    ContentView()
      .previewLayout(.fixed(width: 568, height: 320)) //LandScape
    //여러 개의 preview를 만들 수 있다.
  }
}
