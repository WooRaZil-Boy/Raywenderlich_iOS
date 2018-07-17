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

protocol AddTodoItemDelegate: class {
  func addItemViewControllerDidCancel(_ controller: AddTodoItemTableViewController)
  func addItemViewController(_ controller: AddTodoItemTableViewController, didFinishAdding item: TodoItem)
  func addItemViewController(_ controller: AddTodoItemTableViewController, didFinishEditing item: TodoItem)
}

class AddTodoItemTableViewController: UITableViewController {
    
  // MARK: - Outlets
    
  @IBOutlet weak var textField: UITextField!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  
  // MARK: - Variables
  
  weak var delegate: AddTodoItemDelegate?
  
  var item: TodoItem?
  var editMode: Bool?
    

  // MARK: - Lifecycle Methods

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    textField.becomeFirstResponder()

    if editMode != nil {
      self.title = "Edit Todo Item"
      textField.text = item?.title
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - IBActions
  
  @IBAction func cancel(_ sender: Any) {
    navigationController?.popViewController(animated: true)
    delegate?.addItemViewControllerDidCancel(self)
  }
  
  @IBAction func save(_ sender: Any) {
    if let text = textField.text {
      if editMode != nil {
        item?.title = text
        delegate?.addItemViewController(self, didFinishEditing: item!)
      } else {
        let item = TodoItem(context: PersistenceService.context)
        item.title = text
        item.completed = false
        delegate?.addItemViewController(self, didFinishAdding: item)
      }
    }
  }
}

// MARK: - UITextFieldDelegate

extension AddTodoItemTableViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if let oldText = textField.text {
      let textRange = Range(range, in: oldText)
      let newText = oldText.replacingCharacters(in: textRange!, with: string)
      
      doneButton.isEnabled = !newText.isEmpty
      
    }
    
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField.text!.count > 0 {
      doneButton.isEnabled = true
    }
  }
  
}

// MARK: - UITableViewDelegate

extension AddTodoItemTableViewController {
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return nil
  }

}
