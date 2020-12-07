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
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACTa, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import XCTest
import Combine
import SwiftUI
@testable import ColorCalc

class ColorCalcTests: XCTestCase {
    var viewModel: CalculatorViewModel!
    var subscriptions = Set<AnyCancellable>()

  
  override func setUp() {
    viewModel = CalculatorViewModel()
  }
  
  override func tearDown() {
    subscriptions = []
  }
    
    //Issue 1: Incorrect name displayed
    func test_correctNameReceived() {
        // Given
        let expected = "rwGreen 66%"
        var result = ""
        //이 test에서 예상되는 결과 text를 저장한다.
        
        viewModel.$name
            //viewModel의 $name publisher를 구독한다.
            .sink(receiveValue: { result = $0 })
            //내보낸 값을 저장한다.
            .store(in: &subscriptions)
        
        // When
        viewModel.hexText = "006636AA"
        //예상결과를 발생시키는 작업을 수행한다.
        
        // Then
        XCTAssert(
            result == expected,
            "Name expected to be \(expected) but was \(result)"
        )
        //result와 expected가 같은지 확인한다.
    }
    
    //Issue 2: Tapping backspace deletes two characters
    func test_processBackspaceDeletesLastCharacter() {
        // Given
        let expected = "#0080F"
        var result = ""
        //이 test에서 예상되는 result를 설정하고, 그 result를 저장할 변수를 만든다.
        
        viewModel.$hexText
            //viewModel의 $hexText publisher를 구독한다.
            .dropFirst() //처음 replay된 값을 삭제한다.
            .sink(receiveValue: { result = $0 }) //내보낸 값을 저장한다.
            .store(in: &subscriptions)
        
        // When
        viewModel.process(CalculatorViewModel.Constant.backspace)
        // ← 문자를 나타내는 상수 String을 전달하는 viewModel.process(_:)를 호출한다.
        
        // Then
        XCTAssert(
            result == expected,
            "Hex was expected to be \(expected) but was \(result)"
        )
        //result와 expected가 같은지 확인한다.
    }
    
    //Issue 3: Incorrect background color
    func test_correctColorReceived() {
        // Given
        let expected = Color(hex: ColorName.rwGreen.rawValue)!
        var result: Color = .clear
        
        viewModel.$color
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)
        
        // When
        viewModel.hexText = ColorName.rwGreen.rawValue
        
        // Then
        XCTAssert(
            result == expected,
            "Color expected to be \(expected) but was \(result)"
        )
    }
    
    func test_processBackspaceReceivesCorrectColor() {
        // Given
        let expected = Color.white
        var result = Color.clear
        //expected과 result의 지역 변수를 생성한다.
        
        viewModel.$color
            //이전과 동일하게 viewModel의 $color publisher를 구독한다.
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)
        
        // When
        viewModel.process(CalculatorViewModel.Constant.backspace)
        //hex text를 처리한 이전과 달리 이번에는 backspace의 input을 처리한다.
        
        // Then
        XCTAssert(
            result == expected,
            "Hex was expected to be \(expected) but was \(result)"
        )
        //result와 expected가 같은지 확인한다.
    }
    
    //Testing for bad input
    func test_whiteColorReceivedForBadData() {
        // Given
        let expected = Color.white
        var result = Color.clear

        viewModel.$color
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)
      
        // When
        viewModel.hexText = "abc"
      
        // Then
        XCTAssert(
            result == expected,
            "Color expected to be \(expected) but was \(result)"
        )
    }
    
    //Challenge 1: Resolve Issue 4: Tapping clear does not clear hex display
    func test_processClearSetsHexToHashtag() {
        // Given
        let expected = "#"
        var result = ""

        viewModel.$hexText
            .dropFirst()
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        // When
        viewModel.process(CalculatorViewModel.Constant.clear)

        // Then
        XCTAssert(
            result == expected,
            "Hex was expected to be \(expected) but was \"\(result)\""
        )
    }
    
    //Challenge 2: Resolve Issue 5: Incorrect red-green-blue-opacity display for entered hex
    func test_correctRGBOTextReceived() {
        // Given
        let expected = "0, 102, 54, 170"
        var result = ""

        viewModel.$rgboText
            .sink(receiveValue: { result = $0 })
            .store(in: &subscriptions)

        // When
        viewModel.hexText = "#006636AA"

        // Then
        XCTAssert(
            result == expected,
            "RGBO text expected to be \(expected) but was \(result)"
        )
    }

}





