/*
 * Copyright (c) 2016 Razeware LLC
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

protocol BindableType {
    associatedtype ViewModelType //associatedtype은 하나 이상 프로토콜에 관련있는 타입에 이름을 지정한다.
    
    var viewModel: ViewModelType! { get set }
    //BindableType 프로토콜을 구현하는 View Controller는 연관된 View Model을 viewModel변수에 할당하고,
    //viewModel에 변수가 할당되면, bindViewModel() 함수가 호출된다.
    //bindViewModel를 호출할 때에는 View가 로드된 이후에 할당해야 한다(UI 요소를 연결하기 때문).
    
    func bindViewModel()
    //bindViewModel 함수는 UI 요소를 View Model의 observable과 action에 연결한다.
}

extension BindableType where Self: UIViewController { //UIViewController에서 bindViewModel 구현
    mutating func bindViewModel(to model: Self.ViewModelType) {
        //mutating은 함수 내에서 변수의 값을 바꿔야 할 때 사용.
        viewModel = model //viewModel 변수에 Model 할당
        loadViewIfNeeded() //view가 로드되지 않은 경우, Controller의 뷰를 로드한다(UIViewController).
        bindViewModel()
    }
}

//어떤 시점에서 View Controller를 View Model에 연결하거나 binding 해야 한다.
//이때 BindableType 프로토콜을 구현하면 되도록 작업을 해 준다.
