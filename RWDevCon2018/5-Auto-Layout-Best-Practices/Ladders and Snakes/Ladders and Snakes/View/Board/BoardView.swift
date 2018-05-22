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

import UIKit

class BoardView: UIView {
  @IBOutlet weak var rows: UIStackView!
  
  var squaresInRow: Int {
    return rows.arrangedSubviews.count
  }
  
  var squareWidth: CGFloat {
    return rows.arrangedSubviews.first?.bounds.size.height ?? 0
  }
  
  func square(row: Int, column: Int) -> BoardSquareView? {
    return square(at: BoardLocation(row: row, column: column))
  }
  
  func square(at location: BoardLocation) -> BoardSquareView? {
    guard
      isSquare(at: location),
      let row = rows.arrangedSubviews[location.row] as? UIStackView,
      let loader = row.arrangedSubviews[location.column] as? BoardSquareViewLoader
    else { return nil }
    
    return loader.contentView
  }
  
  func isSquare(at location: BoardLocation) -> Bool {
    let maxIndex = squaresInRow - 1
    let indexRange = 0...maxIndex
    
    return indexRange ~= location.row && indexRange ~= location.column
  }
  
  var finish: BoardSquareView? {
    return square(at: finishLocation)
  }
  
  var finishLocation: BoardLocation {
    return (row: 0, column: 0)
  }
  
  var start: BoardSquareView? {
    return square(at: startLocation)
  }
  
  var startLocation: BoardLocation {
    let max = squaresInRow - 1
    return (row: max, column: max)
  }
  
  func move(piece: PieceView, to square: BoardSquareView, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
    adjustConstraintsToMovePiece(piece: piece, to: square)
    
    // If not animated, just update constraints
    guard animated else {
      layoutIfNeeded()
      return
    }
    
    // Otherwise animate the application of the contraints
    UIView.animate(withDuration: AnimationDuration.standard.rawValue, animations: { [weak self] in
      self?.layoutIfNeeded()
    }, completion: completion)
  }
  
  private func adjustConstraintsToMovePiece(piece: PieceView, to square: BoardSquareView) {
    piece.snp.remakeConstraints { make in
      make.center.equalTo(square)
    }
  }
}
