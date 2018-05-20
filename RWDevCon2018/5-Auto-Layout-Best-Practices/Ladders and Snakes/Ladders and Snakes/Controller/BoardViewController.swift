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
import SnapKit

class BoardViewController: UIViewController {
  
  @IBOutlet weak var board: BoardView!
  
  private var squareWidth: CGFloat = 0
  
  // MARK: - View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    squareWidth = board.squareWidth
    adjustForHiddenNumbers()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    squareWidth = board.squareWidth
    print("Board square width is \(squareWidth)")

    addObstaclesToBoard()
  }
  
  
  // MARK: - Board
  
  private func addObstaclesToBoard() {
    let top = addTopCenteredSnake(to: board)
    let bottomLeft = addBottomLeftSnake(to: board)
    let bottomRight = addBottomRightSnake(to: board)
    
    let right = addRightLeaningLadder(to: board) //사다리 추가
    let left = addLeftLeaningLadder(to: board) //사다리 추가
    
    let obstacles = [top, bottomLeft, bottomRight, right, left]
    obstacles.forEach { $0.fade(to: .shown) }
  }
  
  // MARK: - Board
  
  func adjustForHiddenNumbers() {
    let one = board.squareAt(row: 4, column: 4)
    let fourteen = board.squareAt(row: 2, column: 1)
    let twenty = board.squareAt(row: 1, column: 4)
    let twentyTwo = board.squareAt(row: 0, column: 3)
    
    [one, fourteen, twenty, twentyTwo].forEach { $0?.flip(to: .facesRight) }
  }

  
  // MARK: - Snakes
  
  @discardableResult
  private func addTopCenteredSnake(to view: UIView) -> SnakeView {
    // Will be added in Demo 2.
    let snake = SnakeView.create(size: squareWidth * 2.2)
    view.addSubview(snake)

    // Auto Layout needed here!
    snake.addTopAnchor(to: view, constant: -squareWidth / 2)
    snake.addCenterXAnchor(to: view)
    
    return snake
  }
  
  @discardableResult
  private func addBottomLeftSnake(to view: UIView) -> SnakeView {
    // Will be added in Demo 2.
    let snake = SnakeView.create(size: squareWidth * 2.5, color: .green)
    view.addSubview(snake)
    snake.addBottomAnchor(to: view)
    snake.addLeftAnchor(to: view, constant: squareWidth / 8)
    
    return snake
  }
  
  @discardableResult
  private func addBottomRightSnake(to view: UIView) -> SnakeView {
    // Will be added in Demo 2.
    let snake = SnakeView.create(size: squareWidth * 1.5, color: .purple,
                                 direction: .facesLeft)
    view.addSubview(snake)
    let inset = -squareWidth / 8
    snake.addBottomAnchor(to: view, constant: inset)
    snake.addRightAnchor(to: view, constant: inset)
    
    return snake
  }
  
  
  // MARK: - Ladders
  
  // Will be added in Demo 2.
  
  @discardableResult
  private func addRightLeaningLadder(to view: UIView) -> LadderView {
    //LadderView를 만들고 오른쪽으로 기울인다.
    let span = squareWidth * 2
    let ladder = LadderView.create(size: span, direction: .facesRight)
    view.addSubview(ladder)
    
//    let guide = view.layoutMarginsGuide
//    //레이아웃 가이드 앵커로 뷰 여백으로 제약 조건을 만든다.
//    ladder.centerYAnchor.constraint(equalTo: guide.centerYAnchor, constant: -squareWidth).isActive = true
//    ladder.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
//    //NSLayoutAnchor는 뷰 매개변수에 상대적인 위치를 정하는데 사용된다.
    
    //SnapKit
    ladder.snp.makeConstraints { make in
      make.centerY.equalTo(view).offset(-squareWidth)
      make.right.equalTo(view)
    }
    //SnapKit 라이브러리로 더 간단하게 표현할 수 있다.
    
    return ladder
  }
  
  @discardableResult
  private func addLeftLeaningLadder(to view: UIView) -> LadderView {
    let ladder = LadderView.create(size: squareWidth * 1.8, rotation: 20, direction: .facesLeft)
    //왼쪽으로 20도 회전
    view.addSubview(ladder)

    // Auto Layout required here.
    // Use NSLayoutAnchor abstracted - see UIView+NSLayoutAnchor.swift
    ladder.addCenterYAnchor(to: view, constant:  -squareWidth / 3) //1/3 만큼 위쪽에서 떨어져 있다.
    ladder.addLeftAnchor(to: view)

    return ladder
  }
}
