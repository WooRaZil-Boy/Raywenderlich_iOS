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
import CoreData

class ListViewController: UIViewController {
  
  // MARK: - Outlets

  @IBOutlet var rwTableView: UITableView!
  @IBOutlet var emptyView: UIView!

  // MARK: - Variables
  
  var currentSelectedItem: TodoItem?
  var items: [TodoItem] = []
  
  // MARK: - Constants
  
  let navigationTitle = "Todo List"
  let cellIdentifier = "todoCell"
  let addItemSegue = "AddTodoItemSegue"
  let editItemSegue = "EditTodoItemSegue"
  let editActionTitle = "Edit"
  let deleteActionTitle = "Delete"
  
  // MARK: - Lifecycle Methods
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupUI()
    if items.count > 0 {
      view = rwTableView
    } else {
      view = emptyView
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = navigationTitle
  }
  
  // MARK: - Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == addItemSegue {
      let controller = segue.destination as! AddTodoItemTableViewController
      controller.delegate = self
    } else if segue.identifier == editItemSegue {
      let controller = segue.destination as! AddTodoItemTableViewController
      controller.delegate = self
      controller.editMode = true
      controller.item = currentSelectedItem
    }
    
  }
  
  // MARK: - Functions
  
  private func setupUI() {
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.barStyle = .black
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
    UITableViewCell.appearance().tintColor = UIColor.rwGreen()
  }

  private func configureCheckmark(for cell: UITableViewCell, with item: TodoItem) {
    if item.completed {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }

    PersistenceService.saveContext()
  }
  
  private func configureText(for cell: UITableViewCell, with item: TodoItem) {
    cell.textLabel?.text = item.title
  }
  
  private func getSavedTodos() {
    let fetchedRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
    do {
      let savedTodos = try PersistenceService.context.fetch(fetchedRequest)
      self.items = savedTodos
    } catch {
      print("Error fetching todos")
    }
  }
  
  private func addItemToTableView(item: TodoItem) {
    
    let newRow = items.count
    items.append(item)
    
    let indexPath = IndexPath(row: newRow, section: 0)
    let indexPaths = [indexPath]
    
    rwTableView.insertRows(at: indexPaths, with: .automatic)
  }
  
  private func updateItemInTableView(item: TodoItem) {
    if let index = items.index(of: item) {
      let indexPath = IndexPath(item: index, section: 0)
      if let cell = rwTableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
  }
  
  private func editTodoItem(at indexPath: IndexPath) {
    let item = items[indexPath.row]
    currentSelectedItem = item
    performSegue(withIdentifier: editItemSegue, sender: self)
  }

  private func deleteTodoItem(at indexPath: IndexPath) {
    items.remove(at: indexPath.row)
    let indexPaths = [indexPath]
    rwTableView.deleteRows(at: indexPaths, with: .automatic)
    
    if items.count == 0 {
      view = emptyView
    }
  }
  
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    
    let item = items[indexPath.row]
    
    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      let item = items[indexPath.row]
      item.toggleCompleted()
      configureCheckmark(for: cell, with: item)
    }
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let edit = UITableViewRowAction(style: .default, title: editActionTitle) { (action, indexPath) in
      self.editTodoItem(at: indexPath)
    }
    
    let delete = UITableViewRowAction(style: .destructive, title: deleteActionTitle) { (action, indexPath) in
      self.deleteTodoItem(at: indexPath)
    }
    
    edit.backgroundColor = UIColor.rwGreen()
    delete.backgroundColor = .red
    
    return [delete, edit]
  }

}

// MARK: - AddTodoItemDelegate

extension ListViewController: AddTodoItemDelegate {
  
  func addItemViewControllerDidCancel(_ controller: AddTodoItemTableViewController) {
    navigationController?.popToRootViewController(animated: true)
  }
  
  func addItemViewController(_ controller: AddTodoItemTableViewController, didFinishAdding item: TodoItem) {
    navigationController?.popToRootViewController(animated: true)
    addItemToTableView(item: item)
    PersistenceService.saveContext()
  }
  
  func addItemViewController(_ controller: AddTodoItemTableViewController, didFinishEditing item: TodoItem) {
    navigationController?.popViewController(animated: true)
    updateItemInTableView(item: item)
    PersistenceService.saveContext()
  }
  
}
