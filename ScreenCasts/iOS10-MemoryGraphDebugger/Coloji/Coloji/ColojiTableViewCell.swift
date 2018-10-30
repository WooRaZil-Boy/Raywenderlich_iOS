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

class ColojiTableViewCell: UITableViewCell {
  private let label = ColojiLabel()
  
  var coloji: Coloji? {
    didSet {
      if let coloji = coloji {
        addLabel(coloji: coloji)
      }
    }
  }
  
  private func addLabel(coloji: Coloji) {
    label.coloji = coloji
    if(label.superview == .none) {
      label.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(label)
      NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        label.topAnchor.constraint(equalTo: contentView.topAnchor)
      ])
    }
  }
}

private class ColojiLabel: UILabel {
  var coloji: Coloji? {
    didSet {
      if let coloji = coloji {
        display(coloji: coloji)
      }
    }
  }
  
  private func display(coloji: Coloji) {
    font = UIFont.systemFont(ofSize: 50)
    textAlignment = .center
    switch coloji {
    case .color(let color):
      backgroundColor = color
      text = .none
    case .emoji(let emoji):
      backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
      text = emoji
    }
  }
}
