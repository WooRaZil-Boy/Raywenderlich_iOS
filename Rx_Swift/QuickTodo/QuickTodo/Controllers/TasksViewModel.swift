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
import RxDataSources
import Action

typealias TaskSection = AnimatableSectionModel<String, TaskItem> //섹션 모델

struct TasksViewModel {
  let sceneCoordinator: SceneCoordinatorType
  let taskService: TaskServiceType
    
    var sectionedItems: Observable<[TaskSection]> {
        return self.taskService.tasks() //전체 task를 불러온다.
            .map { results in
                let dueTasks = results //해야할 일
                    .filter("checked == nil")
                    .sorted(byKeyPath: "added", ascending: false)
                
                let doneTasks = results //한 일
                    .filter("checked != nil")
                    .sorted(byKeyPath: "checked", ascending: false)
                
                return [
                    TaskSection(model: "Due Tasks", items: dueTasks.toArray()),
                    TaskSection(model: "Done Tasks", items: doneTasks.toArray())
                ] //섹션 별로 반환
            }
    }

  init(taskService: TaskServiceType, coordinator: SceneCoordinatorType) {
    self.taskService = taskService
    self.sceneCoordinator = coordinator
  }

  func onToggle(task: TaskItem) -> CocoaAction {
    return CocoaAction {
      return self.taskService.toggle(task: task).map { _ in }
    }
  }

  func onDelete(task: TaskItem) -> CocoaAction {
    return CocoaAction {
      return self.taskService.delete(task: task)
    }
  }

  func onUpdateTitle(task: TaskItem) -> Action<String, Void> {
    return Action { newTitle in
      return self.taskService.update(task: task, title: newTitle).map { _ in }
    }
  }
    
    func onCreateTask() -> CocoaAction {
        return CocoaAction { _ in
            return self.taskService
                //self는 구조체이므로 복사본을 가져온다. 따라서 순환참조가 일어나지 않으므로
                //weak self나 unowned self를 써줄 필요 없다.
                .createTask(title: "")
                .flatMap { task -> Observable<Void> in
                    let editViewModel = EditTaskViewModel(task: task, coordinator: self.sceneCoordinator, updateAction: self.onUpdateTitle(task: task), cancelAction: self.onDelete(task: task))
                        //task 객체 생성
                    
                    return self.sceneCoordinator
                        .transition(to: Scene.editTask(editViewModel), type: .modal)
                        .asObservable()
                        .map { _ in}
                }
        }
    }
    
    lazy var editAction: Action<TaskItem, Swift.Never> = { this in //기존 항목 추가
        return Action { task in
            let editViewModel = EditTaskViewModel(
                task: task,
                coordinator: this.sceneCoordinator,
                updateAction: this.onUpdateTitle(task: task)
            )
            return this.sceneCoordinator
                .transition(to: Scene.editTask(editViewModel), type: .modal)
                .asObservable()
        }
    }(self)
}

//RxDataSources의 유일한 제약은 섹션에 사용된 각 유형이 IdentifiableType과 Equatable 프로토콜을 준수해야 한다.
//IdentifiableType은 RxDataSources가 객체를 고유하게 식별하도록 식별자를 선언한다.
//Equatabled은 오브젝트를 비교하여 동일한 고유 오브젝트의 두 사본 사이의 변경 사항 감지한다.

//RxDataSources를 사용하면, 새로 고침 할 필요 없이 Observable 섹션이 새로운 목록 생성 위해 구독하면 다시 로드한다.
