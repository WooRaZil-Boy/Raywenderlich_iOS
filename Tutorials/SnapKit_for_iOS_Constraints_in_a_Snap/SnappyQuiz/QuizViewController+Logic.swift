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

// MARK: - Game Logic
extension QuizViewController {
  @objc func handleAnswer(_ sender: UIButton) {
    let userSelection = sender == btnTrue
    let isCorrect = state.question.isTrue == userSelection
    
    if isCorrect {
      state.correctAnswers += 1
    }
    
    showMessage(isCorrect: isCorrect)
  }
  
  func showMessage(isCorrect: Bool) {
    lblMessage.text = isCorrect ? "That's correct!\n👍🎉😄" : "Sorry, that's wrong!\n\n👎☠️😢"
    lblMessage.textColor = isCorrect ? .green : .red
    lblMessage.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    lblMessage.alpha = 0
    timer?.invalidate()
    
    UIView.animate(withDuration: 0.7,
                   delay: 0.0,
                   usingSpringWithDamping: 0.4,
                   initialSpringVelocity: 0.8,
                   options: .curveEaseIn,
                   animations: {
                    self.lblMessage.alpha = 1
                    self.lblMessage.transform = .identity
                   },
                   completion: { _ in
                    UIView.animate(withDuration: 0.15,
                                   delay: 0.35,
                                   animations: {
                                    self.lblMessage.alpha = 0
                                   },
                                   completion: { _ in
                                    self.goToNextQuestion()
                                   })
                   })
  }
  
  func goToNextQuestion() {
    guard !state.isLastQuestion else {
      // This is the last question
      let alert = UIAlertController(title: "Good job!",
                                    message: "You got \(state.correctAnswers) out of \(state.numberOfQuestions) right.",
                                    preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "Start Over",
                                    style: .default,
                                    handler: { [weak self] _ in self?.startGame() }))
      
      present(alert, animated: true, completion: nil)
      return
    }
    
    goToQuestion(at: state.currentQuestion + 1)
  }
  
  func goToQuestion(at position: Int) {
    state.currentQuestion = position
    
    lblQuestion.text = state.question.title
    navigationItem.title = "SnappyQuiz \(position)/\(state.numberOfQuestions)"
    
    let progress = Double(position) / Double(state.numberOfQuestions)
    updateProgress(to: progress)
    startCountdown()
  }
  
  func startGame() {
    state = State(questions: questions)
    goToQuestion(at: 1)
  }
  
  func startCountdown() {
    lblTimer.text = "00:10"
    
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
      guard let self = self else { return }
      
      let currentSeconds = Int((self.lblTimer.text ?? "0").replacingOccurrences(of: ":", with: "")) ?? 1
      
      guard currentSeconds > 1 else {
        timer.invalidate()
        self.goToNextQuestion()
        return
      }
      
      self.lblTimer.text = "00:0\(currentSeconds - 1)"
    }
  }
}
