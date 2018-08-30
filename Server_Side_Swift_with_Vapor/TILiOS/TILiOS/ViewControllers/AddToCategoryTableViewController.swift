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

class AddToCategoryTableViewController: UITableViewController {

  // MARK: - Properties
  var categories: [Category] = [] //API에서 retrieve해서 가져온 모든 카테고리 배열
  var selectedCategories: [Category]! //해당 acronym의 카테고리
  var acronym: Acronym!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }

  func loadData() {
    let categoriesRequest = ResourceRequest<Category>(resourcePath: "categories")
     //카테고리에 대한 ResourceRequest 생성
    categoriesRequest.getAll { [weak self] result in
      //API에서 모든 카테고리를 가져온다.
      
      switch result {
      case .failure: //실패 시
        ErrorPresenter.showError(message: "There was an error getting the categories", on: self) { _ in
          self?.navigationController?.popViewController(animated: true)
        }
      case .success(let categories): //성공 시
        self?.categories = categories //카테고리 업데이트
        DispatchQueue.main.async { [weak self] in
          self?.tableView.reloadData() //테이블 뷰 리로드
        }
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension AddToCategoryTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
    let category =  categories[indexPath.row]
    cell.textLabel?.text = category.name
    let isSelected = selectedCategories.contains { element in
      element.name == category.name
    }
    if isSelected {
      cell.accessoryType = .checkmark
    }
    return cell
  }
}

// MARK: - UITableViewDelegate
extension AddToCategoryTableViewController {

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let category = categories[indexPath.row] //사용자가 선택한 카테고리를 가져온다.
    
    guard let acronymID = acronym.id else { //해당 Acronym이 유효한 id인지 확인
      let message = """
      There was an error adding the acronym
      to the category - the acronym has no ID
      """
      ErrorPresenter.showError(message: message, on: self)
      return
    }
    
    let acronymRequest = AcronymRequest(acronymID: acronymID) //acronymRequest 생성
    acronymRequest.add(category: category) { [weak self] result in
      //API로 DB의 해당 Acronym에 카테고리 추가 update(_: completion:) 메서드 실행
      
      switch result {
      case .success:
        DispatchQueue.main.async { [weak self] in
          self?.navigationController?.popViewController(animated: true)
          //이전 ViewController로 돌아간다.
        }
      case .failure:
        let message = """
        There was an error adding the acronym
        to the category
        """
        ErrorPresenter.showError(message: message, on: self)
      }
    }
  }
}
