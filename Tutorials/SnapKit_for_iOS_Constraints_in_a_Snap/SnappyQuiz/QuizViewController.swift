/// Copyright (c) 2019 Razeware LLC
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

class QuizViewController: UIViewController {
  /// Curent game state
  var state = State(questions: questions)
  
  /// Current question countdown timer
  var timer: Timer?
  
//  /// Progress bar constraint
//  var progressConstraint: NSLayoutConstraint!

  // MARK: - Views
  lazy var viewProgress: UIView = {
    let v = UIView(frame: .zero)
    v.backgroundColor = .green
    
    view.addSubview(v)
    
    return v
  }()
  
  lazy var lblTimer: UILabel = {
    let lbl = UILabel(frame: .zero)
    lbl.layer.cornerRadius = 8
    lbl.layer.borderColor = UIColor.black.cgColor
    lbl.layer.borderWidth = 2
    lbl.textAlignment = .center
    lbl.font = UIFont.systemFont(ofSize: 20, weight: .light)
    lbl.text = "00:10"
    
    view.addSubview(lbl)
    
    return lbl
  }()
  
  lazy var lblQuestion: UILabel = {
    let lbl = UILabel(frame: .zero)
    lbl.textAlignment = .center
    lbl.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    lbl.text = "Question placeholder"
    lbl.numberOfLines = 0
    
    view.addSubview(lbl)
    
    return lbl
  }()
  
  lazy var btnTrue: UIButton = {
    let btn = UIButton(type: .custom)
    btn.layer.cornerRadius = 12
    btn.backgroundColor = .green
    btn.setTitle("👍True", for: .normal)
    btn.setTitleColor(.black, for: .normal)
    btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
    btn.showsTouchWhenHighlighted = true
    btn.addTarget(self, action: #selector(handleAnswer(_:)), for: .touchUpInside)
    
    return btn
  }()
  
  lazy var btnFalse: UIButton = {
    let btn = UIButton(type: .custom)
    btn.layer.cornerRadius = 12
    btn.backgroundColor = .red
    btn.setTitle("👎False", for: .normal)
    btn.setTitleColor(.black, for: .normal)
    btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .semibold)
    btn.showsTouchWhenHighlighted = true
    btn.addTarget(self, action: #selector(handleAnswer(_:)), for: .touchUpInside)
    
    return btn
  }()
  
  lazy var svButtons: UIStackView = {
    let stackView = UIStackView(arrangedSubviews: [btnFalse, btnTrue])
    stackView.alignment = .center
    stackView.spacing = 16
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    
    view.addSubview(stackView)
    
    return stackView
  }()
  
  lazy var lblMessage: UILabel = {
    let lbl = UILabel(frame: .zero)
    lbl.numberOfLines = 0
    lbl.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    lbl.textAlignment = .center
    lbl.font = UIFont.systemFont(ofSize: 48, weight: .semibold)
    lbl.alpha = 0
    
    self.navigationController?.view.addSubview(lbl)
    
    return lbl
  }()
  
  // - MARK: Setup
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.largeTitleDisplayMode = .always
    navigationController?.navigationBar.prefersLargeTitles = true
    
    setupConstraints()
    startGame()
  }
}
