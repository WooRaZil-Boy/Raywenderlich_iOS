//
//  Constants.swift
//  Bullseye
//
//  Created by youngho on 2021/01/17.
//

import Foundation
import UIKit

enum Constants {
  enum General {
    public static let strokeWidth = CGFloat(2.0)
    public static let roundedViewLength = CGFloat(56.0)
    public static let roundedRectViewWidth = CGFloat(68.0)
    public static let roundedRectViewHeight = CGFloat(56.0)
    public static let roundedRectCornerRadius = CGFloat(21.0)
  }
  
  enum Leaderboard {
    public static let leaderboardScoreColWidth = CGFloat(50.0)
    public static let leaderboardDateColWidth = CGFloat(170.0)
    public static let leaderboardMaxRowWidth = CGFloat(480.0)
  }
}

//반복되는 값을 하드코딩 하기 보다, 상수로 선언해서 관리하는 것이 좋다.
