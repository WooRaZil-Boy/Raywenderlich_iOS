//
//  LeaderboardView.swift
//  Bullseye
//
//  Created by youngho on 2021/01/17.
//

import SwiftUI

struct LeaderboardView: View {
  @Binding var leaderboardIsShowing: Bool
  @Binding var game: Game
  
  var body: some View {
    ZStack {
      Color("BackgroundColor")
        .ignoresSafeArea(.all)
      VStack(spacing: 10) {
        HeaderView(leaderboardIsShowing: $leaderboardIsShowing)
        LabelView()
        ScrollView {
          VStack(spacing: 10) {
            ForEach(game.leaderboardEntries.indices) { i in
              let leaderboardEntry = game.leaderboardEntries[i]
              RowView(index: i, score: leaderboardEntry.score, date: leaderboardEntry.date)
            }
          }
        }
      }
    }
  }
}

struct RowView: View {
  let index: Int
  let score: Int
  let date: Date
  
  var body: some View {
    HStack {
      RoundedTextView(text: String(index))
      Spacer()
      ScoreText(score: score)
        .frame(width: Constants.Leaderboard.leaderboardDateColWidth)
      Spacer()
      DateText(date: date)
        .frame(width: Constants.Leaderboard.leaderboardDateColWidth)
    }
      .background(
        RoundedRectangle(cornerRadius: .infinity)
          .strokeBorder(Color("LeaderboardRowColor"), lineWidth: Constants.General.strokeWidth)
      )
      .padding(.leading)
      .padding(.trailing)
      .frame(maxWidth: Constants.Leaderboard.leaderboardMaxRowWidth)
  }
}

struct HeaderView: View {
  @Binding var leaderboardIsShowing: Bool
  @Environment(\.verticalSizeClass) var verticalSizeClass
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  var body: some View {
    ZStack { //ZStack은 기본적으로 정가운데 정렬된다.
      HStack {
        if verticalSizeClass == .regular && horizontalSizeClass == .compact {
          //작은 화면 device의 portarait 모드 일 때 HeaderView의 Text가 잘리는 버그를 해결한다.
          BigBoldText(text: "Leaderboard")
            .padding(.leading)
          Spacer()
        } else {
          BigBoldText(text: "Leaderboard")
        }
      }
      .padding(.top)
      HStack { //여기서 HStack 사용하여 우측 끝으로 위치하도록 한다.
        Spacer()
        Button(action: {
          leaderboardIsShowing = false
        }, label: {
          RoundedImageViewFilled(systemName: "xmark")
            .padding(.trailing)
        })
      }
    }
  }
}

struct LabelView: View {
  var body: some View {
    HStack {
      Spacer()
        .frame(width: Constants.General.roundedViewLength)
      Spacer()
      LabelText(text: "Score")
        .frame(width: Constants.Leaderboard.leaderboardScoreColWidth)
      Spacer()
      LabelText(text: "Date")
        .frame(width: Constants.Leaderboard.leaderboardDateColWidth)
    }
      .padding(.leading)
      .padding(.trailing)
      .frame(maxWidth: Constants.Leaderboard.leaderboardMaxRowWidth)
  }
}

//https://useyourloaf.com/blog/size-classes 에서 각 device의 verticalSize와 horizontalSize를 확인할 수 있다.

struct LeaderboardView_Previews: PreviewProvider {
  static private var leaderboardIsShowing = Binding.constant(false)
  static private var game = Binding.constant(Game(loadTestData: true))
  
  static var previews: some View {
    LeaderboardView(leaderboardIsShowing: leaderboardIsShowing, game: game)
    LeaderboardView(leaderboardIsShowing: leaderboardIsShowing, game: game)
      .previewLayout(.fixed(width: 568, height: 320))
    LeaderboardView(leaderboardIsShowing: leaderboardIsShowing, game: game)
      .preferredColorScheme(.dark)
    LeaderboardView(leaderboardIsShowing: leaderboardIsShowing, game: game)
      .preferredColorScheme(.dark)
      .previewLayout(.fixed(width: 568, height: 320))
  }
}
