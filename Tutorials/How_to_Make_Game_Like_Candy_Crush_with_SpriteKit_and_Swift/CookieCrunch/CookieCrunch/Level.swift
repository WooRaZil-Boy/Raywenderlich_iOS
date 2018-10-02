/// Copyright (c) 2018 Razeware LLC
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

let numColumns = 9 //열
let numRows = 9 //행

class Level {
  private var cookies = Array2D<Cookie>(columns: numColumns, rows: numRows) //2차원 배열을 생성한다.
  private var tiles = Array2D<Tile>(columns: numColumns, rows: numRows) //Level의 구조를 설명한다.
  //레벨 그리드의 어느 부분이 비어 있고, 어느 부분이 쿠키를 포함할 수 있는 지 정보를 설명한다.
  
    init(filename: String) {
      guard let levelData = LevelData.loadFrom(file: filename) else { return }
      //JSON 파일에서 데이터를 불러온다. nil을 반환하면 종료한다.
      
      let tilesArray = levelData.tiles //타일 배열 생성
    
      for (row, rowArray) in tilesArray.enumerated() { //행
        let tileRow = numRows - row - 1 //(0, 0)은 좌측 하단이므로 행의 순서를 바꿔야 한다. JSON의 첫 행은 2D 그리드의 마지막 행이 된다.
        
        for (column, value) in rowArray.enumerated() { //열
          if value == 1 { //값이 1인 경우 쿠키가 있을 수 있다. 0인 경우는 비어 있다(비어있는 상태가 아니라 아예 아무 객체도 들어갈 수 없음).
            tiles[column, tileRow] = Tile() //Tile 객체를 만들어 배열에 추가한다.
          }
        }
      }
    }
  
  func cookie(atColumn column: Int, row: Int) -> Cookie? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    //precondition()으로 지정된 열과 행이 유효 범위 안에 있는 지 확인한다.
    //precondition()는 assert()와 비슷하며 역할도 같다.
    //precondition()는 릴리즈 버전에서도 해당 오류가 발생하면 앱이 종료된다.
    
    return cookies[column, row]
    //만약 cookie(atColumn: 3, row: 6)을 호출한다면, 2차원 배열에서 (3, 6)에 있는 쿠키를 반환한다.
    //모든 격자가 쿠키를 가진 것이 아니므로 반환형은 optional이 된다.
  }
  
  func shuffle() -> Set<Cookie> { //임의의 쿠키로 레벨을 채운다.
    return createInitialCookies()
  }
  
  private func createInitialCookies() -> Set<Cookie> {
    var set: Set<Cookie> = [] //Set은 배열과 같은 Collection이지만 각 요소를 하나만 가질 수 있으며 순서가 없다.
    
    for row in 0..<numRows { //행 반복
      for column in 0..<numColumns { //열 반복
        if tiles[column, row] != nil { //해당 타일 객체가 비어 있지 않은 경우(1인 경우) //init(filename:) 참고
          let cookieType = CookieType.random() //랜덤하게 쿠키 유형을 가져온다.
          
          let cookie = Cookie(column: column, row: row, cookieType: cookieType) //새로운 쿠키를 만들어
          cookies[column, row] = cookie //2차원 배열에 추가한다.
          
          set.insert(cookie) //Set에 추가한다.
        }
      }
    }
    
    return set
    //설계 시 어려운 점은 서로 다른 객체끼리 값을 주고 받으며 커뮤니케이션하는 것이다. 이 게임에서는 주로 2차원 배열과 Set으로 데이터를 전달한다.
  }
}

//9x9 게임이 된다. 총 81개의 격자를 포함하는 2차원 배열을 만든다.




//Loading Levels from JSON Files
//Levels 폴더의 JSON 파일에는 각 level에 대한 정보가 있다. tiles, targetScore, moves 정보가 있으며, tiles에서 1인 경우 쿠키가 있을 수 있고 0은 비어있다.
extension Level {
  func tileAt(column: Int, row: Int) -> Tile? {
    precondition(column >= 0 && column < numColumns)
    precondition(row >= 0 && row < numRows)
    
    return tiles[column, row]
  }
}
