///// Copyright (c) 2018 Razeware LLC
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

import Foundation

enum AnimationDuration: Double {
  case standard = 0.9
}

class GameEngine {
  
  private var obstacles: [Obstacle] = []
  
  func setupObstacles() {
    let headOne = BoardLocation(row: 3, column: 4)
    let tailOne = BoardLocation(row: 4, column: 3)
    let snakeOne = Obstacle(start: headOne, end: tailOne)
    
    let headTwo = BoardLocation(row: 2, column: 2)
    let tailTwo = BoardLocation(row: 3, column: 0)
    let snakeTwo = Obstacle(start: headTwo, end: tailTwo)
    
    let headThree = BoardLocation(row: 0, column: 3)
    let tailThree = BoardLocation(row: 1, column: 1)
    let snakeThree = Obstacle(start: headThree, end: tailThree)
    
    let bottomOne = BoardLocation(row: 2, column: 1)
    let topOne = BoardLocation(row: 1, column: 0)
    let ladderOne = Obstacle(start: bottomOne, end: topOne)
    
    let bottomTwo = BoardLocation(row: 2, column: 3)
    let topTwo = BoardLocation(row: 0, column: 4)
    let ladderTwo = Obstacle(start: bottomTwo, end: topTwo)
    
    obstacles = [snakeOne, snakeTwo, snakeThree, ladderOne, ladderTwo]
  }
  
  func obstacleEncountered(at location: BoardLocation) -> Obstacle? {
    return obstacles.filter { $0.start == location }.first
  }
  
  func generateDiceResult() -> Int {
    return Int(arc4random_uniform(6) + 1)
  }
  
  func calculateFinalLocation(on board: BoardView, current: BoardLocation, move by: Int) -> BoardLocation {
    var rowIndex = current.row
    var columnIndex = current.column
    let maxIndex = board.squaresInRow - 1
    
    let movingLeft = current.row % 2 == 0
    let remaining = movingLeft ? current.column : maxIndex - current.column
    
    if by > remaining {
      let rowAdjustment = (by == 6 && columnIndex == 0 && movingLeft) ? 2 : 1
      rowIndex -= rowAdjustment
      
      columnIndex = by - remaining - rowAdjustment
      if !movingLeft {
        columnIndex = maxIndex - columnIndex
      }
    }
    else {
      columnIndex = movingLeft ? columnIndex - by : columnIndex + by
    }
    
    let calculated = BoardLocation(row: rowIndex, column: columnIndex)
    guard board.isSquare(at: calculated) else {
      return board.finishLocation
    }
    return calculated
  }
  
}
