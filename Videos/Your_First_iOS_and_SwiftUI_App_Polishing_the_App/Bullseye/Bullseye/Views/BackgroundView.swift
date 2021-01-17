//
//  BackgroundView.swift
//  Bullseye
//
//  Created by youngho on 2021/01/17.
//

import SwiftUI

struct BackgroundView: View {
  @Binding var game: Game
  
  var body: some View {
    VStack{
      TopView(game: $game)
      Spacer()
      BottomView(game: $game)
    }
      .padding()
      .background(
        RingsView()
      )
  }
}

struct TopView: View {
  @Binding var game: Game
  @State private var leaderboardIsShowing = false
  
  var body: some View {
    HStack {
      Button(action: {
        game.restart()
      }, label: {
        RoundedImageViewStroked(systemName: "arrow.counterclockwise")
      })
      Spacer()
      Button(action: {
        leaderboardIsShowing = true
      }, label: {
        RoundedImageViewFilled(systemName: "list.dash")
      })
        .sheet(isPresented: $leaderboardIsShowing, onDismiss: {}, content: {
          //이전의 alert과 마찬가지로, sheet를 호출한다. dismiss될 때 leaderboardIsShowing 값이 자동으로 변경된다.
          LeaderboardView(leaderboardIsShowing: $leaderboardIsShowing, game: $game)
        })
    }
  }
}

struct NumberView: View {
  var title: String
  var text: String
  
  var body: some View {
    VStack(spacing: 5) {
      LabelText(text: title.uppercased())
      RoundRectTextView(text: text)
    }
  }
}

struct BottomView: View {
  @Binding var game: Game
  
  var body: some View {
    HStack {
      NumberView(title: "Score", text: String(game.score))
      Spacer()
      NumberView(title: "Round", text: String(game.round))
    }
  }
}

struct RingsView: View {
  @Environment(\.colorScheme) var colorScheme //환경 변수
  
  var body: some View {
    ZStack {
//      Color(red: 243.0 / 255.0, green: 248.0 / 255.0, blue: 253.0 / 255.0)
      //Color(red:green:blue:)에서 입력하는 값은 0 ~ 1 사이 값이므로, 255.0으로 나눠 정규화해 줘야 한다.
      Color("BackgroundColor")
      //해당 Asset Catalog에서 정의한 색상을 가져온다.
        .edgesIgnoringSafeArea(.all) //SafeArea를 무시한다.
        //해당 modifier가 없으면, status bar 등이 있기 때문에 위 아래로 Color가 꽉 차게 들어가지 않는다.
      ForEach(1..<6) { ring in
        let size = CGFloat(ring * 100)
        let opacity = colorScheme == .dark ? 0.1 : 0.3 //Light, Dark 모드에 따라 opacity가 달라진다.
        Circle()
          .stroke(lineWidth: Constants.General.strokeWidth)
          .fill(
            RadialGradient(gradient: Gradient(colors: [Color("RingsColor").opacity(opacity),
                                                       Color("RingsColor").opacity(0)]),
                           center: .center,
                           startRadius: 100,
                           endRadius: 300)
          )
          .frame(width: size, height: size)
      }
    }
  }
}

struct BackgroundView_Previews: PreviewProvider {
  static var previews: some View {
    BackgroundView(game: .constant(Game()))
    //constant로 해당 인스턴스를 전달해 준다.
  }
}
