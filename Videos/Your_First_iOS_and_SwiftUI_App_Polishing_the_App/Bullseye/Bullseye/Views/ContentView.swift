//
//  ContentView.swift
//  Bullseye
//
//  Created by Ray Wenderlich on 10/16/20.
//

import SwiftUI

struct ContentView: View {
  @State private var alertIsVisible = false
  @State private var sliderValue = 50.0
  @State private var game = Game()

  var body: some View {
    ZStack { //해당 View에서 ⌘ + Click 한 후, Embeded in Zstack 을 사용하면 쉽게 생성할 수 있다.
      BackgroundView(game: $game)
      VStack {
        InstructionsView(game: $game)
          .padding(.bottom, alertIsVisible ? 0 : 100)
//        SliderView(sliderValue: $sliderValue)
        //이대로 두면, padding 때문에 SliderView가 가운데에 위치하지 않는다.
        if alertIsVisible {
          PointsView(alertIsVisible: $alertIsVisible, sliderValue: $sliderValue, game: $game)
            .transition(.scale)
        } else {
          HitMeButton(alertIsVisible: $alertIsVisible,
                      sliderValue: $sliderValue,
                      game: $game)
            .transition(.scale)
        }
      }
      if !alertIsVisible {
        SliderView(sliderValue: $sliderValue)
        //ZStack을 사용해 가운데에 위치하도록 변경한다.
      }
    }
  }
}

struct InstructionsView: View {
  @Binding var game: Game
  //single source of truth을 위해, @State가 아닌 @Binding으로 사용한다.
  
  var body: some View {
    VStack { //하나의 View를 반환해야 하므로, VStack으로 감싸준다.
      InstructionText(text: "🎯🎯🎯\nPut the Bullseye as close as you can to")
        .padding(.leading, 30.0)
        .padding(.trailing, 30.0)
        //해당 modifier는 모든 Text에 적용할 것이 아니라, 여기에서만 적용하는 것이므로 공통적으로 사용하지 않고 따로 빼준다.
      BigNumberText(text: String(game.target))
    }
  }
}

struct SliderView: View {
  @Binding var sliderValue: Double
  //single source of truth을 위해, @State가 아닌 @Binding으로 사용한다.
  
  var body: some View {
    HStack {
      SliderLabelText(text: "1")
      Slider(value: $sliderValue, in: 1.0...100.0)
      SliderLabelText(text: "100")
    }
      .padding()
  }
}

struct HitMeButton: View {
  @Binding var alertIsVisible: Bool
  @Binding var sliderValue: Double
  @Binding var game: Game
  //single source of truth을 위해, @State가 아닌 @Binding으로 사용한다.
  
  var body: some View {
    Button(action: {
      withAnimation {
        alertIsVisible = true
      }
//      game.startNewRound(points: game.points(sliderValue: Int(sliderValue)))
        //여기에서 값을 업데이트하면, UI가 변경되면서 다음 round의 새로운 target이 생성되기 때문에
        //Alert에서의 text는 새 target으로 점수를 계산하여 버그의 원인이 된다.
    }) {
      Text("Hit me".uppercased())
        .bold()
        .font(.title3)
    }
      .padding(20.0)
    .background(
      ZStack { //해당 View에서 ⌘ + Click 한 후, Embeded in Zstack 을 사용한다.
        Color("ButtonColor")
        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.3), Color.clear]),
                       startPoint: .top,
                       endPoint: .bottom)
        //그라디언트를 지정해준다. 순서에 주의해야 한다.
      })
      .foregroundColor(Color.white)
      .cornerRadius(Constants.General.roundedRectCornerRadius)
      .overlay( //오버레이로 버튼의 윤곽선을 지정해 준다.
        RoundedRectangle(cornerRadius: Constants.General.roundedRectCornerRadius)
          .strokeBorder(Color.white, lineWidth: Constants.General.strokeWidth)
      )
//      .alert(isPresented: $alertIsVisible, content: {
//        let roundedValue = Int(sliderValue.rounded())
//        let points = game.points(sliderValue: Int(sliderValue))
//        return Alert(title: Text("Hello there!"),
//                     message: Text("The slider's value is \(roundedValue).\n" + "You scored \(points) points this round."),
//                     dismissButton: .default(Text("Awesome!")) {
//                      game.startNewRound(points: points)
//                     })
//      })
    //Custom Alert으로 대체한다.
  }
}

//extension으로 정의해 주는 대신, Asset Catalog에서 Color를 정의해 줄 수 있다.
//Asset Catalog에서 좌측 하단의 + 버튼을 눌러, Color set을 추가해 준다.
//여기서는 Light, Dark 모드에 상관없이 하나의 배경색을 지정하려면, Attributes Inspector에서 None을 선택해 준다.
//Input Method에서 Hex 값을 입력하거나, 255 8bit 값을 지정해서 색상을 준다.
//같은 방법으로 ButtonColor도 생성해 준다.

//Asset Catalog에는 built-in된 AccentColor도 있다.
//이는 시스템에서 사용하는 강조색으로, control 전반에 기본적으로 사용된다.
//Attributes Inspector의 Color Section에서 content를 sRGB로 선택한 다음 Hex값을 입력해 준다.
//여기에서는 Slider의 색상이 변경되게 된다.

//preview의 Color Scheme를 변경하여 Dark 모드로 preview를 확인할 수 있다.
//해당 속성을 설정하면, 밑의 ContentView_Previews 구조체에 해당 modifier가 추가된다.

//Dark 모드의 배경색을 지정하려면 Asset Catalog의 해당 Color를 선택하고, Attributes Inspector애서 Any, Dark를 선택한다.
//Light 모드의 색상은 Any, Dark 모드의 색상은 Dark에 지정하면 된다.

//TextColor도 해당 모드에 맞춰주기 위해 위와 같은 방식으로 생성한다.

//https://developer.apple.com/sf-symbols/에서 SF-Symbol을 확인하고 다운로드 받을 수 있다.

//Asset Catalog의 AppIcon에서 앱의 아이콘 image를 설정해 준다.
//Project 설정의 Display Name에서 iPhone의 서랍에서 보여주는 앱의 이름을 지정해 줄 수 있다.

//시뮬레이터에서 잘 실행되더라도, 실제 Device에서 실행해 보는 것이 좋다.

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
    ContentView()
      .previewLayout(.fixed(width: 568, height: 320))
    ContentView()
      .preferredColorScheme(.dark)
    ContentView()
      .preferredColorScheme(.dark)
      .previewLayout(.fixed(width: 568, height: 320))
  }
  //필요한 만큼 옵션을 다르게 하여 preview를 설정할 수 있다.
}
