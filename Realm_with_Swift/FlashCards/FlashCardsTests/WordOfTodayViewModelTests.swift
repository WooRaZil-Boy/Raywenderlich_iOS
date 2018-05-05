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

import XCTest

@testable import FlashCards

class WordOfTodayViewModelTests: XCTestCase {
  
  func test_initialState_whenInitialized() {

  }

  func test_correctCurrentWord_whenWordUpdated() {
    let testWOD = RealmProvider.wordOfDay.copyForTesting()
    
    testWOD.realm.addForTesting(objects: [WordOfDayList(list: [Entry(word: "word1", entry: "entry1")])])
    
    let testSettings = RealmProvider.settings.copyForTesting()
    let appSettings = Settings()
    
    testSettings.realm.addForTesting(objects: [appSettings])
    
    let vm = WordOfTodayViewModel(wordOfDay: testWOD, settings: testSettings)
    
    XCTAssertEqual(appSettings.lastTimeWODChanged, Date.distantPast)
    XCTAssertNil(appSettings.wordOfTheDay)
    //초기 설정이 실제로 Settings 클래스의 wordOfTheDay, lastTimeWODChanged에 대해 수정되지 않은 기본값임을 확인
    
    let testWord = testWOD.realm.objects(WordOfDayList.self)[0].list[0]
    vm.updateWord(to: testWord) //해당 날짜의 현재 단어 설정
    //View Model이 settings Realm에 저장된 날짜를 즉시 업데이트 한다.
    
    XCTAssertEqual(appSettings.wordOfTheDay?.word, testWord.word)
    XCTAssertEqual(appSettings.lastTimeWODChanged.timeIntervalSinceReferenceDate, Date().timeIntervalSinceReferenceDate, accuracy: 0.5)
    //초기화한 값과 비교
  }
}
