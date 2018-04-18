/*
 * Copyright (c) 2014-2017 Razeware LLC
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

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import Testing

class TestingViewModel : XCTestCase {

  var viewModel: ViewModel!
  var scheduler: ConcurrentDispatchQueueScheduler!

  override func setUp() {
    super.setUp()
    
    viewModel = ViewModel() //ViewModel 테스트
    scheduler = ConcurrentDispatchQueueScheduler(qos: .default) //Qos : quality of Service
    //Concurrent scheduler에 할당
  }
    
    func testColorIsRedWhenHexStringIsFF0000_async() {
        //setUp 코드
        let disposeBag = DisposeBag()
        let expect = expectation(description: #function)
        //expectation으로 비동기 작업이 완료될 때 수행되는 XCTestExpectation를 만들 수 있다.
        //기대값을 확인하려면, fulfill()을 호출한다.
        let expectedColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        //기대값 RGB
        var result: UIColor! //결과
        
        viewModel.color.asObservable() //viewModel.color Driver
            .skip(1) //Driver가 구독시 초기 요소를 replay 하므로 첫 값은 건너 뛴다.
            .subscribe(onNext: { //구독
                result = $0 //결과에 요소 할당
                expect.fulfill() //기대값 출력
            })
            .disposed(by: disposeBag)
        
        viewModel.hexString.value = "#ff0000" //viewModel.hexString에 값 입력
        
        waitForExpectations(timeout: 1.0) { error in //timeout 시간을 1초로 지정(시간 넘어가면 오류)
            //지정된 시간 내로 값을 받으면 반환하고, 오류가 발생했거나 시간이 초과 됐으면 erorr
            guard error == nil else {
                XCTFail(error!.localizedDescription)
                return
            }
        }
        
        XCTAssertEqual(expectedColor, result)
    }
    
    func testColorIsRedWhenHexStringIsFF0000() { //RxBlocking을 사용하여 구현
        let colorObservable = viewModel.color.asObservable().subscribeOn(scheduler) //구독
        viewModel.hexString.value = "#ff0000" //viewModel.hexString에 값 입력
        
        do {
            guard let result = try colorObservable.toBlocking(timeout:1.0).first() else
                //1초 를 timeout으로 바인딩
            { return }
            //fulfill을 사용하지 않고 구현할 수 있다.
            XCTAssertEqual(result, .red)
        } catch { //오류시 출력
            print(error)
        }
    }
    
    func testRgbIs010WhenHexStringIs00FF00() { //testColorIsRedWhenHexStringIsFF0000와 같은 로직
        let rgbObservable = viewModel.rgb.asObservable().subscribeOn(scheduler) //구독
        viewModel.hexString.value = "#00ff00" //viewModel.hexString에 값 입력
        
        let result = try! rgbObservable.toBlocking().first()!
        
        XCTAssertEqual(0 * 255, result.0)
        XCTAssertEqual(1 * 255, result.1)
        XCTAssertEqual(0 * 255, result.2)
    }
    
    func testColorNameIsRayWenderlichGreenWhenHexStringIs006636() { //같은 로직 //색상 명 테스트
        let colorNameObservable = viewModel.colorName.asObservable().subscribeOn(scheduler) //구독
        viewModel.hexString.value = "#006636"
        
        XCTAssertEqual(try! colorNameObservable.toBlocking().first()!, "rayWenderlichGreen")
    }
}
