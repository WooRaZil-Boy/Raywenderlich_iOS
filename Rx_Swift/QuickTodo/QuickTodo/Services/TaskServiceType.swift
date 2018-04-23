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
import RealmSwift

enum TaskServiceError: Error {
  case creationFailed
  case updateFailed(TaskItem)
  case deletionFailed(TaskItem)
  case toggleFailed(TaskItem)
}

protocol TaskServiceType {
    //프로토콜을 사용하여 공용 서비스 인터페이스를 정의한다.
    //모든 데이터를 Observable 시퀀스로 표현한다.
    //Observable을 완료하여, 작업의 실패 또는 성공 여부를 전달한다.
    @discardableResult
    //@discardableResult선언 속성은 반환값을 무시할 수 있다.
    //함수의 반환값을 별도로 사용하지 않는 경우에 경고가 뜨는 데 그것을 없앨 수 있다.
    func createTask(title: String) -> Observable<TaskItem> //Task 생성
    
    @discardableResult
    func delete(task: TaskItem) -> Observable<Void> //Task 삭제
    
    @discardableResult
    func update(task: TaskItem, title: String) -> Observable<TaskItem> //Task 업데이트
    
    @discardableResult
    func toggle(task: TaskItem) -> Observable<TaskItem> //Task 체크
    func tasks() -> Observable<Results<TaskItem>> //쿼리
}

//TaskServices는 Storage에서 Task 항목을 생성하고 업데이트 한다.

