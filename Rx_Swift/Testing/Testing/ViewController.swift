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

import UIKit
import RxSwift
import RxCocoa

class ViewController : UIViewController {
  
  @IBOutlet weak var hexTextField: UITextField!
  @IBOutlet weak var rgbTextField: UITextField!
  @IBOutlet weak var colorNameTextField: UITextField!
  
  @IBOutlet var textFields: [UITextField]! //각 텍스트 필드들의 배열
  
  @IBOutlet weak var zeroButton: UIButton!
  @IBOutlet var buttons: [UIButton]! //각 입력 버튼들의 배열
  
  let disposeBag = DisposeBag()
  let viewModel = ViewModel()
  
  let backgroundColor = PublishSubject<UIColor>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureUI()
    
    guard let textField = self.hexTextField else { return }
    
    textField.rx.text.orEmpty
      .bind(to: viewModel.hexString) //텍스트 필트의 텍스트(or 빈 문자열)를 hexString에 바인딩
      .disposed(by: disposeBag)
    
    for button in buttons { //버튼들을 loop
      button.rx.tap //탭 시
        .bind { //바인딩
          var shouldUpdate = false
          
          switch button.titleLabel!.text! {
          case "⊗":
            textField.text = "#"
            shouldUpdate = true
          case "←" where textField.text!.count > 1:
            textField.text = String(textField.text!.dropLast())
            shouldUpdate = true
          case "←":
            break
          case _ where textField.text!.count < 7:
            textField.text!.append(button.titleLabel!.text!)
            shouldUpdate = true
          default:
            break
          }
          
          if shouldUpdate {
            textField.sendActions(for: .valueChanged)
            //valueChanged 이벤트 보내야 하는 경우 텍스트 업데이트
          }
        }
        .disposed(by: disposeBag)
    }
    
    viewModel.color
      .drive(onNext: { [unowned self] color in
        UIView.animate(withDuration: 0.2) {
          self.view.backgroundColor = color //배경 색 업데이트
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.rgb
      .map { "\($0.0), \($0.1), \($0.2)" } //RGB 텍스트 업데이트
      .drive(rgbTextField.rx.text)
      .disposed(by: disposeBag)
    
    viewModel.colorName
      .drive(colorNameTextField.rx.text) //색상 명 텍스트 업데이트
      .disposed(by: disposeBag)
  }
  
  func configureUI() {
    textFields.forEach {
      $0.layer.shadowOpacity = 1.0
      $0.layer.shadowRadius = 0.0
      $0.layer.shadowColor = UIColor.lightGray.cgColor
      $0.layer.shadowOffset = CGSize(width: -1, height: -1)
    }
  }
}

//MVVM 패턴. 색상코드를 입력하면, RGB값 및 색상 이름을 얻는 앱
//RxTest는 RxSwift와 별도의 라이브러리이다. TestScheduler로 시간을 스케줄해 선형 작업을 테스트 할 수 있다.
//next(_: _:), complted(_ : _:), error(_: _:) 등의 메서드를 제어한다.

//• Hot obserables
//  subscribe 여부에 상관없이 리소스를 사용한다.
//  subscribe 여부에 상관없이 요소들을 생산한다.
//  주로 Variable 같은 상태 저장 유형과 함께 사용된다.
//• Cold observables
//  Subscription 상에서만 리소스를 사용한다.
//  Subscribers가 있는 경우에만 요소들을 생산한다.
//  주로 네트워킹과 같은 비동기 작업에 사용된다.








