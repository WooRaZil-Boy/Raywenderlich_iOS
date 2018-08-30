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

class AcronymDetailTableViewController: UITableViewController {
  
  // MARK: - Properties
  var acronym: Acronym? {
    didSet {
      updateAcronymView()
    }
  }
  
  var user: User? {
    didSet {
      updateAcronymView()
    }
  }
  
  var categories: [Category] = [] {
    didSet {
      updateAcronymView()
    }
  }
  
  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.prefersLargeTitles = false
    getAcronymData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    getAcronymData()
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "EditAcronymSegue" { //edit 시
      guard let destination = segue.destination as? CreateAcronymTableViewController else {
        return
      }
      
      destination.acronym = acronym
      //속성 설정
    } else if segue.identifier == "AddToCategorySegue" { //카테고리 추가 시
      guard let destination = segue.destination as? AddToCategoryTableViewController else {
        return
      }
      
      destination.acronym = acronym
      destination.selectedCategories = categories
      //속성 설정
    }
  }
  
  func getAcronymData() {
    guard let id = acronym?.id else { //nil 여부 판단
      return
    }
    
    let acronymDetailRequester = AcronymRequest(acronymID: id)
    //API와 통신할 AcronymRequest 를 생성한다.
    acronymDetailRequester.getUser { [weak self] result in
      //API에서 해당 Acronym id로 User를 얻는다.
      
      switch result {
      case .success(let user):
        self?.user = user //user 속성 업데이트
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the acronym's user", on: self)
      }
    }
    
    acronymDetailRequester.getCategories { [weak self] result in
      //API에서 해당 Acronym id로 Category(배열)을 얻는다.
      
      switch result {
      case .success(let categories):
        self?.categories = categories //categories 속성 업데이트
      case .failure:
        ErrorPresenter.showError(message: "There was an error getting the acronym's categories", on: self)
      }
    }
  }
  
  func updateAcronymView() {
    DispatchQueue.main.async { [weak self] in
      self?.tableView.reloadData()
    }
  }
  
  
  // MARK: - IBActions
  @IBAction func updateAcronymDetails(_ segue: UIStoryboardSegue) {
    guard let controller = segue.source as? CreateAcronymTableViewController else {
      //source로 세그먼트가 출발한 뷰를 가져올 수 있다. 세그먼트가 CreateAcronymTableViewController에서 왔는지 확인
      //즉, Acronym 업데이트 성공 후, unwind 해서 돌아왔을 경우
      return
    }
    
    acronym = controller.acronym
    //DB에 업데이트된 정보 반영
  }
}

// MARK: - UITableViewDataSource
extension AcronymDetailTableViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 5
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return section == 3 ? categories.count : 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AcronymDetailCell", for: indexPath)
    cell.selectionStyle = .none
    cell.isUserInteractionEnabled = false
    //해당 속성들은 deafault가 비 활성화이고, Acronym에 카테고리 추가하는 셀만 활성화 된다.
    
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = acronym?.short
    case 1:
      cell.textLabel?.text = acronym?.long
    case 2:
      cell.textLabel?.text = user?.name
    case 3:
      cell.textLabel?.text = categories[indexPath.row].name
    case 4: //해당 Acronym에 카테고리 추가 일 때만 활성화
      //해당 셀만 선택이 가능해 진다.
      cell.textLabel?.text = "Add To Category"
      cell.selectionStyle = .default
      cell.isUserInteractionEnabled = true
    default:
      break
    }

    return cell
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Acronym"
    case 1:
      return "Meaning"
    case 2:
      return "User"
    case 3:
      return "Categories"
    default:
      return nil
    }
  }
}
