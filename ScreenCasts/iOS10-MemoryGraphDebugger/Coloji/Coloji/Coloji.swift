/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class ColojiCellFormatter {
  let coloji: Coloji
  
  private let massiveWasteOfMemory = Data(bytes: [UInt8](repeatElement(0, count: 10 * 1024)))
  
  lazy var configureCell: (UITableViewCell) -> () = {
    [unowned self] cell in //[unowned self]을 사용해 메모리 누수를 막는다.
    if let colojiCell = cell as? ColojiTableViewCell {
      colojiCell.coloji = self.coloji
    }
  }
  
  init(coloji: Coloji) {
    self.coloji = coloji
  }
}

enum Coloji {
  case color(UIColor)
  case emoji(String)
}


func createColoji(color: UIColor) -> Coloji {
  usleep(100_000)
  return Coloji.color(color)
}

func createColoji(emoji: String) -> Coloji {
  usleep(100_000)
  return Coloji.emoji(emoji)
}
