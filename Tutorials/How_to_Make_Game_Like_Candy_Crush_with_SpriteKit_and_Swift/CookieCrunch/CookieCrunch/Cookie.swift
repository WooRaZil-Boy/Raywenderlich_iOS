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

import SpriteKit

// MARK: - CookieType
enum CookieType: Int {
  case unknown = 0, croissant, cupcake, danish, donut, macaroon, sugarCookie
  //0은 특별한 의미를 가진다.
  
  var spriteName: String { //해당 enum에 해당하는 쿠키의 이름을 가져온다(이미지 파일 이름이 된다).
    let spriteNames = [
      "Croissant",
      "Cupcake",
      "Danish",
      "Donut",
      "Macaroon",
      "SugarCookie"
    ]
    
    return spriteNames[rawValue - 1] //0이 unknown 이므로 1을 빼준다.
  }
  
  var highlightedSpriteName: String { //사용자가 쿠키를 탭하면 강조 표시된 이미지 파일을 가져온다.
    return spriteName + "-Highlighted"
  }
  
  static func random() -> CookieType { //임의의 쿠키 유형을 생성한다.
    return CookieType(rawValue: Int.random(in: 1...6))!
  }
  
  //Swift에서의 enum 은 단순히 열거하는 것 이상의 기능을 구현할 수 있다.
}

// MARK: - Cookie
class Cookie: CustomStringConvertible, Hashable {
  //CustomStringConvertible 프로토콜은 description을 구현하여 출력을 쉽게 한다.
  //Hashable 프로토콜은 Set에 넣을 객체라면 반드시 구현해야 한다.
  var column: Int //그리드에서의 위치(열)
  var row: Int //그리드에서의 위치(행)
  let cookieType: CookieType //쿠키의 유형(열거형)
  var sprite: SKSpriteNode? //쿠키 객체가 항상 있는 것은 아니기에 optional
  
  init(column: Int, row: Int, cookieType: CookieType) {
    self.column = column
    self.row = row
    self.cookieType = cookieType
  }
  
  var hashValue: Int {
    return row * 10 + column
  }
  
  static func ==(lhs: Cookie, rhs: Cookie) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row
  }
  
  var description: String {
    return "type:\(cookieType) square:(\(column),\(row))"
  }
}

//이 게임은 9x9로 구성되어 있다. 각 격자는 쿠키를 포함할 수 있다.
//0,0은 왼쪽 하단을 나타낸다. UIKit과는 거꾸로, 일반 좌표계의 위치를 생각하면 된다.

//Cookie 클래스가 SKSpriteNode를 상속하지 않는 이유는 Cookie 는 단순히 데이터를 설명하는 Model 객체이기 때문이다.
//View는 별도의 객체이며, sprite 속성에 저장된다(즉, view에서 표시하는 객체는 따로 있다).
//이런 MVC 패턴은 게임에서는 조금 덜 일반적이지만, 코드를 깨끗하고 유연하게 유지하는 데 도움을 준다.
