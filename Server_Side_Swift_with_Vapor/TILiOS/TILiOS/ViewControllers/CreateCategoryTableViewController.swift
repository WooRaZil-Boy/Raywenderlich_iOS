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

class CreateCategoryTableViewController: UITableViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var nameTextField: UITextField!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    nameTextField.becomeFirstResponder()
  }

  // MARK: - IBActions
  @IBAction func cancel(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: Any) { //CreateUserTableViewController의 save(_:) 메서드와 유사
    guard let name = nameTextField.text, !name.isEmpty else {
      //name 입력 텍스트 필드가 비어 있는지 확인
      ErrorPresenter.showError(message: "You must specify a name", on: self)
      return
    }
    
    let category = Category(name: name) //입력된 데이터로 새로운 category 생성
    
    ResourceRequest<Category>(resourcePath: "categories").save(category) { [weak self] result in
      //생성된 category로, ResourceRequest 생성해 save(_: completion:) 메서드 실행
      switch result {
      case .failure: //저장 실패
        let message = "There was a problem saving the category"
        ErrorPresenter.showError(message: message, on: self)
      case .success: //저장 성공
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
          //이전 ViewController로 돌아간다.
        }
      }
    }
  }
}
