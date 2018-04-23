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

import Foundation
import RxSwift
import Action

struct EditTaskViewModel {

  let itemTitle: String
  let onUpdate: Action<String, Void>!
  let onCancel: CocoaAction!
  let disposeBag = DisposeBag()

  init(task: TaskItem, coordinator: SceneCoordinatorType, updateAction: Action<String, Void>, cancelAction: CocoaAction? = nil) {
    itemTitle = task.title
    onUpdate = updateAction
    onCancel = CocoaAction { //취소
        //생성자에 의해 수신된 작업은 선택사항이므로 취소할 때까지 호출자가 아무것도 할 수 없으므로 새 작업을 생성
        if let cancelAction = cancelAction {
            cancelAction.execute(())
        }
        return coordinator.pop()
            .asObservable().map { _ in }
    }
    
    onUpdate.executionObservables
        //액션이 실행될 때 새로운 Observable을 emit하는 executionObservables 구독
        .take(1) //OK 버튼에 바인딩 되므로 한 번만 실행된다.
        .subscribe(onNext: { _ in
            coordinator.pop()
        })
        .disposed(by: disposeBag)
  }
}

//RxDataSources를 사용하면 다음과 같은 장점이 있다.
//• section으로 나뉜 TableView와 Collection View를 지원한다.
//• 알고리즘이 효율적으로 짜여 있어, 삭제, 삽입, 업데이트 등의 작업에 최적화된다.
//• 삭제, 삽입, 업데이트에 애니메이션 추가 가능하다.
//• section 애니메이션과 item 애니메이션을 모두 지원한다.
//RxDataSources를 사용하면, 어떤 작업 없이도 자동으로 애니메이션을 추가할 수 있는 것이 가장 큰 장점이다.
//RxCocoa 바인딩보다 이해하기 어려운 게 단점.
//가장 간단한 방법은 섹션의 유형으로 SectionModel 또는 AnimatableSectionModel 제네릭 유형을 사용하는 것이다.
