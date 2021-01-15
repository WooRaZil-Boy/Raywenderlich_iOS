//
//  Game.swift
//  Bullseye
//
//  Created by youngho on 2021/01/16.
//

import Foundation

struct Game {
  var target = Int.random(in: 1...100)
  var score = 0
  var round = 1
  
  func points(sliderValue: Int) -> Int {
//    var difference: Int
//    if sliderValue > self.target {
//      difference = sliderValue - self.target
//    } else if self.target > sliderValue {
//      difference = self.target - sliderValue
//    } else {
//      difference = 0
//    }
//
//    var awardedPoints: Int = 100 - difference
//    return awardedPoints
    
//    var difference: Int = self.target - sliderValue
//    if difference < 0 {
//      difference = difference * -1
//      //difference *= -1 혹은 difference = -difference 으로 쓸 수도 있다.
//    }
//
//    var awardedPoints: Int = 100 - difference
//    return awardedPoints
    
    
//    let difference = abs(target - sliderValue)
//    let awardedPoints = 100 - difference
//    return awardedPoints
    
//    return 100 - abs(target - sliderValue)
    
    100 - abs(target - sliderValue)
  }
}

//single responsibility principle에 맞춰서 View와 Model을 나눠서 작성해 주는 것이 좋다.
