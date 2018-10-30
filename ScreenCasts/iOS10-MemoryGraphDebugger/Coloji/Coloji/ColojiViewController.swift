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

class ColojiViewController: UIViewController {
  
  var coloji: Coloji?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    createLayout()
  }
  
  private func createLayout() {
    guard let coloji = coloji else { return }
    
    switch coloji {
    case .color(let color):
      layoutFor(color: color)
    case .emoji(let emoji):
      layoutFor(emoji: emoji)
    }
  }
  
  private func layoutFor(color: UIColor) {
    view.backgroundColor = color
  }
  
  private func layoutFor(emoji: String) {
    view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    let emojiLabel = UILabel()
    view.addSubview(emojiLabel)
    emojiLabel.text = emoji
    emojiLabel.font = UIFont.systemFont(ofSize: 100)
    emojiLabel.sizeToFit()
    emojiLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emojiLabel.widthAnchor.constraint(equalTo: view.widthAnchor),
      emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
  }
}
