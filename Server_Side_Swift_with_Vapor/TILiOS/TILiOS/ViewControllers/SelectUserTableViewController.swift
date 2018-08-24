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

class SelectUserTableViewController: UITableViewController {

  // MARK: - Properties
  var users: [User] = []
  var selectedUser: User! //선택된 사용자

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }

  func loadData() {
    let usersRequest = ResourceRequest<User>(resourcePath: "users")
    //User에 대한 ResourceRequest 생성. API에서 User 결과를 요청하고 가져온다.
    
    usersRequest.getAll { [weak self] result in
      //getAll을 호출해서, 모든 User를 가져온다. 클로저의 파라미터인 result에 반환된 모든 데이터가 있다.
      switch result {
      case .failure: //request 실패 시
        let message = "There was an error getting the users"
        ErrorPresenter.showError(message: message, on: self) { _ in
          //오류를 표시하고, 이전 View로 돌아간다.
          self?.navigationController?.popViewController(animated: true)
        }
      case .success(let users): //request 성공 시
        self?.users = users //사용자 저장
        
        DispatchQueue.main.async { [weak self] in
          self?.tableView.reloadData() //테이블 뷰 리로드
        }
      }
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "UnwindSelectUserSegue" { //셀을 선택할 때
      guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
        return
      }
      
      selectedUser = users[indexPath.row] //사용자가 선택한 셀의 user로 selectedUser 업데이트
    }
  }
}

// MARK: - UITableViewDataSource
extension SelectUserTableViewController {

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return users.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let user = users[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "SelectUserCell", for: indexPath)
    cell.textLabel?.text = user.name
    
    if user.name == selectedUser.name { //현재 셀의 User와 selectedUser를 비교한다.
      cell.accessoryType = .checkmark //동일한 경우 체크 표시
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
}
