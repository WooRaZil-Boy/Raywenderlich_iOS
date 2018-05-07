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
import UIKit

#if EXAMS_V1_5
  
  struct ExamCellViewModel {
    let title: String
    let subTitle: String
    let exam: Exam //1.5에서 추가

    let formatter: DateFormatter = {
      let f = DateFormatter()
      f.dateStyle = .medium
      f.timeStyle = .short
      return f
    }()

    init(exam: Exam) {
      guard let subject = exam.subject else {
        title = "Invalid exam record"
        subTitle = ""
        self.exam = exam //1.5에서 추가
        
        return
      }
      
      self.exam = exam
      title = (exam.isMultipleChoice ? "☒ ": "")
        //exam이 객관식이면 ☒
        .appending(subject.name)
        .appending(exam.result != nil ? "(\(exam.result!))": "")
        //exam result가 있는 경우 대괄호로 결과를 표시
      subTitle = "\(subject.credits) credits "
        .appending( exam.date != nil ? formatter.string(from: exam.date!) : "")
    }

    func setExamSelected() -> Bool {
      //View Model을 변경하고, 사용자가 해당 테이블 행을 누를 때 exam 상태를 업데이트 한다.
      //View Controller는 exam이 탭될 때, View Model에서 해당 메서드(setExamSelected)를 호출한다.
      guard exam.result == nil, let realm = exam.realm else {
        return false
      }
      
      try! realm.write {
        exam.result = "I’ve passed the exam!"
      }
      
      return true
    }
  }
  
#endif

//마이그레이션 로직 작성 전에 새로운 기능으로 앱의 UI를 업데이트해야 한다.
