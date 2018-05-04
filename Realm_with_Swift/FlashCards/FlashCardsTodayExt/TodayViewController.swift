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

import UIKit
import NotificationCenter
import RealmSwift

class TodayViewController: UIViewController, NCWidgetProviding { //위젯

  @IBOutlet private var word: UILabel!
  @IBOutlet private var details: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Word of Today"
    updateUI(word: "Loading...", details: "Launch the app one time to get started with this widget")
  }

  private func updateUI(word: String, details: String) {
    self.word.text = word
    self.details.text = details
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) { //시스템이 주기적으로 호출하여 위젯 UI 업데이트
    guard let appSettings = Settings.in(realm: RealmProvider.settings.realm), let wordOfTheDay = appSettings.wordOfTheDay, wordOfTheDay.word != word.text else {
      //RealmProvider.settings에서 설정 객체, wordOfTheDay, 현재 단어와 비교해서 모두 유효할 때만 실행
      //RealmProvider 구조체가 앱과 extension에서 공유되므로 손쉽게 구현이 가능하다.
      //RealmProvider.settings은 동일한 응용 프로그램 그룹의 shared 컨테이너를 가리키고 동일한 settings.realm 파일을 가리킨다.
      completionHandler(.noData) //데이터 없음
      
      return
    }
    
    updateUI(word: wordOfTheDay.word, details: wordOfTheDay.entry)
    completionHandler(.newData)
  }
}
