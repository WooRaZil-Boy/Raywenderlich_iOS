/// Copyright (c) 2021 Razeware LLC
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

import SwiftUI

//struct GridView: View {
//struct GridView<Content>: View where Content: View {
struct GridView<Content, T>: View where Content: View { //제네릭
  var columns: Int
  var items: [T]
  let content: (T) -> Content
  
  var numberRows: Int {
    guard  items.count > 0 else {
      return 0
    }
    
    return (items.count - 1) / columns + 1
  }
  
  init(columns: Int, items: [T],
       @ViewBuilder content: @escaping (T) -> Content) {
    self.columns = columns
    self.items = items
    self.content = content
  }
  
  func elementFor(row: Int, column: Int) -> Int? {
    let index = row * self.columns + column
    return index < items.count ? index : nil
  }

  var body: some View {
    GeometryReader { geometry in
      ScrollView {
        VStack {
          ForEach(0..<self.numberRows) { row in
            //언급했듯이 이제, VStack 내부의 row을 반복한다.
            //0부터 시작하여 행의 수보다 1작은 수만큼 반복한다.
            //array와 마찬가지로 3개의 row을 0, 1, 2로 지정한다.
            HStack {
              ForEach(0..<self.columns) { column in
                //row의 수를 알고 있으므로, 0에서 시작하여 column의 수보다 1적은 수 만큼 반복한다.
                
  //              Text("\(self.items[row * self.columns + column])")
                
  //              if self.elementFor(row: row, column: column) != nil {
  //                Text("\(self.items[self.elementFor(row: row, column: column)!])")
  //              }
                //이전에서 preview에서 if let 구문을 사용할 수 없었지만, iOS14 이후 부터 가능
                
  //              if let index = self.elementFor(row: row, column: column) {
  //                Text("\(self.items[index])")
  //              } else {
  //                Text("")
  //              }
                //array의 요소를 표시하려면, row과 column에 해당하는 index를 계산한다.
                //array는 0에서 시작하므로, rows과 columns을 0부터 세기 시작하면 이 계산이 더 간단해진다.
                //각 row의 번호에 각 row의 columns 수를 곱한다.
                
                Group {
                  if let index = self.elementFor(row: row, column: column) {
                    self.content(
                      self.items[index]
                    )
                    .frame(width: geometry.size.width / CGFloat(self.columns),
                           height: geometry.size.width / CGFloat(self.columns))
                  } else {
                    Spacer()
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

struct GridView_Previews: PreviewProvider {
  static var previews: some View {
//    GridView(columns: 2, items: [11, 3, 7, 17, 5, 2, 1])
//    GridView(columns: 3, items: [11, 3, 7, 17, 5, 2, 1])
    GridView(columns: 3, items: [11, 3, 7, 17, 5, 2, 1]) { item in
      Text("\(item)")
    }
  }
}



