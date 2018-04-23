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
import Action
import RxSwift

class TaskItemTableViewCell: UITableViewCell {

  @IBOutlet var title: UILabel!
  @IBOutlet var button: UIButton!
  var disposeBag = DisposeBag()

  func configure(with item: TaskItem, action: CocoaAction) {
    button.rx.action = action //체크 표시 바인딩
    
    item.rx.observe(String.self, "title")
        .subscribe(onNext: { [weak self] title in
            self?.title.text = title
        })
        .disposed(by: disposeBag)
    
    item.rx.observe(Date.self, "checked")
        .subscribe(onNext: { [weak self] date in
            let image = UIImage(named: date == nil ? "ItemNotChecked" : "ItemChecked") //이미지
            self?.button.setImage(image, for: .normal)
        })
        .disposed(by: disposeBag)
  }
    
    override func prepareForReuse() { //셀 재사용 시. //구독이 종료되지 않도록 주의해야 한다.
        button.rx.action = nil
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}

//task를 만들거나 편집할 때 Modal Controller를 표시하고 작업(업데이트, 삭제)를 다시 View Model에 전파해야 한다.
//목록은 Realm에서 자동으로 업데이트 된다.
//이 작업 패턴은 다음과 같은 로직을 따른다.
//• 편집 Secene를 준비할 때 하나 이상의 Action을 전달한다. 편집 Scene는 task를 수행하고 종료할 때 적절한 동작
//  (업데이트, 취소)를 실행한다.
//• caller는 컨텍스트에 따라 다른 작업을 전달할 수 있으며, 편집 Scene에서는 차이를 알 수 없다.
//  삭제를 전달하거나 취소를 전달한다. p.419


