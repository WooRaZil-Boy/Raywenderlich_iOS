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

class CreateAcronymTableViewController: UITableViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var acronymShortTextField: UITextField!
  @IBOutlet weak var acronymLongTextField: UITextField!
  @IBOutlet weak var userLabel: UILabel!

  // MARK: - Properties
  var selectedUser: User?
  var acronym: Acronym?

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    acronymShortTextField.becomeFirstResponder()
    
    if let acronym = acronym { //edit mode
      acronymShortTextField.text = acronym.short
      acronymLongTextField.text = acronym.long
      userLabel.text = selectedUser?.name
      navigationItem.title = "Edit Acronym" //ViewController title 설정
    } else { //save mode
      populateUsers()
    }
  }
  
  func populateUsers() {
    //Acronym을 생성할 때, user ID를 입력한다.
    //앱의 사용자가 직접 UUID를 기억해 입력하는 것은 비현실적이므로, User를 선택해 UUID 값을 가져오도록 한다.
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
        DispatchQueue.main.async { [weak self] in
          self?.userLabel.text = users[0].name //User 이름으로 업데이트
        }
        self?.selectedUser = users[0] //selectedUser 업데이트
      }
    }
  }

  // MARK: - IBActions
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    navigationController?.popViewController(animated: true)
  }

  @IBAction func save(_ sender: UIBarButtonItem) {
    guard let shortText = acronymShortTextField.text, !shortText.isEmpty else { //short 변수 유효성 검증
      ErrorPresenter.showError(message: "You must specify an acronym!", on: self)
      return
    }
    
    guard let longText = acronymLongTextField.text, !longText.isEmpty else { //long 변수 유효성 검증
      ErrorPresenter.showError(message: "You must specify a meaning!", on: self)
      return
    }
    
    guard let userID = selectedUser?.id else { //userID 변수 유효성 검증
      let message = "You must have a user to create an acronym!"
      ErrorPresenter.showError(message: message, on: self)
      return
    }
    
    let acronym = Acronym(short: shortText, long: longText, userID: userID)
    //입력한 정보로 Acronym 생성
    
    if self.acronym != nil { //Update
      guard let existingID = self.acronym?.id else { //id가 유효한지 확인
        let message = "There was an error updating the acronym"
        ErrorPresenter.showError(message: message, on: self)
        return
      }
      
      AcronymRequest(acronymID: existingID).update(with: acronym) { result in
        //생성된 acronym로, ResourceRequest 생성해 update(_: completion:) 메서드 실행
        switch result {
        case .failure: //업데이트 실패
          let message = "There was a problem saving the acronym"
          ErrorPresenter.showError(message: message, on: self)
        case .success(let updatedAcronym): //업데이트 성공
          self.acronym = updatedAcronym //DB에 업데이트 된 acronym를 설정해 준다.
          
          DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "UpdateAcronymDetails", sender: nil)
            //unwind segue 트리거
          }
        }
      }
    } else { //Create
      ResourceRequest<Acronym>(resourcePath: "acronyms").save(acronym) { [weak self] result in
        //생성된 acronym로, ResourceRequest 생성해 save(_: completion:) 메서드 실행
        switch result {
        case .failure: //저장 실패
          let message = "There was a problem saving the acronym"
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

  @IBAction func updateSelectedUser(_ segue: UIStoryboardSegue) {
    guard let controller = segue.source as? SelectUserTableViewController else {
      //source로 세그먼트가 출발한 뷰를 가져올 수 있다. 세그먼트가 SelectUserTableViewController에서 왔는지 확인
      //즉, SelectUserTableViewController에서 사용자를 선택하고 돌아왔을 경우
      return
    }
    
    selectedUser = controller.selectedUser //selectedUser 업데이트
    userLabel.text = selectedUser?.name //userLabel 업데이트
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "SelectUserSegue" {
      //CreateAcronymTableViewController에서 SelectUserTableViewController로 갈 때
      guard let destination = segue.destination as? SelectUserTableViewController, let user = selectedUser else {
        //selectedUser의 nil 여부 확인
        return
      }
      
      destination.selectedUser = user
      //SelectUserTableViewController의 selectedUser를 현재 ViewController의 selectedUser로 설정해 준다.
    }
  }
}
