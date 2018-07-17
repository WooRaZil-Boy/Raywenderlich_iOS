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

/// TodoListDelegate has two functions
/// show: Displays the items on the screen
/// error: Displays an error graphic
protocol TodoListDelegate: class {
  func show(items: [TodoItem])
  func error()
}

/// TodoListPersistenceManagerInputDelegate has two functions
/// retrieveTodoItems: Gets the todos from the local store
/// save: Saves a todo item to the local store
protocol TodoListPersistenceManagerInputDelegate: class {
  func retrieveTodoList() throws -> [TodoItem]
  func save(item: TodoItem) throws
}

/// TodoListPersistenceManagerOutputDelegate has two functions
/// onTodoItemsRetrieved: Called when you get back items from the local store
/// onError: If there is an error in retrieving those items
protocol TodoListPersistenceManagerOutputDelegate: class {
  func onTodoItemsRetrieved(_ todos: [TodoItem])
  func onError()
}

/// TodoListInteractorInputDelegate has one property and one function
/// var dataManager: A reference to the data manager protocol
/// retrieveTodoList: Retrieves the todo list from the persistance manager
protocol TodoListInteractorInputDelegate: class {
  var dataManager: TodoListPersistenceManagerInputDelegate? { get set }
  
  func retrieveTodoList()
}

/// TodoListInteractorOutputDelegate has two functions
/// didRetrieveTodos: When retrieveTodoList has completed
/// onError: If there is an error while getting the list
protocol TodoListInteractorOutputDelegate: class {
  func didRetrieveTodos(_ todos: [TodoItem])
  func onError()
}

//프로토콜은 특정 작업이나 기능에 적합한 메서드, 속성 및 기타 요구 사항을 표시한 청사진을 정의하는 데 사용한다.
//나중에 정의되는 클래스에서 프로토콜을 구현해서 사용한다.

