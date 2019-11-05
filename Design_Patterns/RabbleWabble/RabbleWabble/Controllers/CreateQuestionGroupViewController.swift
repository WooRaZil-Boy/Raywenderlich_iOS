/// Copyright (c) 2019 Razeware LLC
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

public protocol CreateQuestionGroupViewControllerDelegate {

  func createQuestionGroupViewControllerDidCancel(_ viewController: CreateQuestionGroupViewController)

  func createQuestionGroupViewController(_ viewController: CreateQuestionGroupViewController,
                                         created questionGroup: QuestionGroup)
}

public class CreateQuestionGroupViewController: UITableViewController {

  // MARK: - Properties
  public var delegate: CreateQuestionGroupViewControllerDelegate?
  public let questionGroupBuilder = QuestionGroupBuilder() //Builder Pattern
    //QuestionGroupBuilder의 모든 속성에 기본값을 설정했기 때문에 따로 전달할 인자가 없다.

  public override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView()
  }

  // MARK: - IBActions
  @IBAction func cancelPressed(_ sender: Any) {
    delegate?.createQuestionGroupViewControllerDidCancel(self)
  }

  @IBAction func savePressed(_ sender: Any) {
    // TODO: - Notify save pressed
    do {
        let questionGroup = try questionGroupBuilder.build()
        delegate?.createQuestionGroupViewController(self, created: questionGroup)
    } catch { //오류 발생
        displayMissingInputsAlert()
    }
  }
    
    public func displayMissingInputsAlert() {
        let alert = UIAlertController(title: "Missing Inputs", message: "Please provide all non-optional values", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension CreateQuestionGroupViewController {

  fileprivate struct CellIdentifiers {
    fileprivate static let add = "AddQuestionCell"
    fileprivate static let title = "CreateQuestionGroupTitleCell"
    fileprivate static let question = "CreateQuestionCell"
  }

  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return questionGroupBuilder.questions.count + 2
    //CreateQuestionGroupViewController는 3가지 유형의 TableViewCell을 표시한다.
    //QuestionGroup의 title, QuestionBuilder, QuestionBuilder 이다.
    //따라서 전체 셀의 수는 questionGroupBuilder.questions.count + 2이 된다.
  }

  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let row = indexPath.row
    if row == 0 {
      return titleCell(from: tableView, for: indexPath)
    } else if row >= 1 && row <= questionGroupBuilder.questions.count {
      return self.questionCell(from: tableView, for: indexPath)
    } else {
      return addQuestionGroupCell(from: tableView, for: indexPath)
    }
  }

  private func titleCell(from tableView: UITableView,
                         for indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.title,
                                             for: indexPath) as! CreateQuestionGroupTitleCell
    cell.delegate = self

    // TODO: - Configure the cell
    cell.titleTextField.text = questionGroupBuilder.title

    return cell
  }

  private func  questionCell(from tableView: UITableView,
                             for indexPath: IndexPath) -> UITableViewCell {
    //주어진 indexPath에서 QuestionBuilder를 사용해, CreateQuestionCell를 생성한다.
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.question,
                                             for: indexPath) as! CreateQuestionCell
    cell.delegate = self

    // TODO: - Configure the cell
    let questionBuilder = self.questionBuilder(for: indexPath)
    cell.delegate = self
    cell.answerTextField.text = questionBuilder.answer
    cell.hintTextField.text = questionBuilder.hint
    cell.indexLabel.text = "Question \(indexPath.row)"
    cell.promptTextField.text = questionBuilder.prompt

    return cell
  }
    
  private func questionBuilder(for indexPath: IndexPath) -> QuestionBuilder {
      //주어진 indexPath에 대한 QuestionBuilder를 가져오는 helper method
      return questionGroupBuilder.questions[indexPath.row - 1]
  }

  private func addQuestionGroupCell(from tableView: UITableView,
                                    for indexPath: IndexPath) -> UITableViewCell {
    return tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.add,
                                         for: indexPath)
  }
}

// MARK: - UITableViewDelegate
extension CreateQuestionGroupViewController {

  // TODO: - Add `UITableViewDelegate` methods
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableViewCell이 탭될 때마다 호출된다.
      tableView.deselectRow(at: indexPath, animated: true)
      guard isLastIndexPath(indexPath) else { return } //isLastIndexPath와 일치하는 지 확인
        //마지막 indexPath를 탭한 것이라면, "add" cell을 탭한 것이다.
      questionGroupBuilder.addNewQuestion() //추가
      tableView.insertRows(at: [indexPath], with: .top)
    }

    private func isLastIndexPath(_ indexPath: IndexPath) -> Bool {
      return indexPath.row ==
        tableView.numberOfRows(inSection: indexPath.section) - 1
    }
}

// MARK: - CreateQuestionCellDelegate
extension CreateQuestionGroupViewController: CreateQuestionCellDelegate {

  public func createQuestionCell(_ cell: CreateQuestionCell,
                                 answerTextDidChange text: String) {
    // TODO: - Write this
    questionBuilder(for: cell).answer = text
  }

  public func createQuestionCell(_ cell: CreateQuestionCell,
                                 hintTextDidChange text: String) {
    // TODO: - Write this
    questionBuilder(for: cell).hint = text
  }

  public func createQuestionCell(_ cell: CreateQuestionCell,
                                 promptTextDidChange text: String) {
    // TODO: - Write this
    questionBuilder(for: cell).prompt = text
  }
    
    private func questionBuilder(for cell: CreateQuestionCell) -> QuestionBuilder  {
        //주어진 Cell에 대한 QuestionBuilder를 결정한다.
        let indexPath = tableView.indexPath(for: cell)!
        return questionBuilder(for: indexPath)
    }
}

// MARK: - CreateQuestionGroupTitleCellDelegate
extension CreateQuestionGroupViewController: CreateQuestionGroupTitleCellDelegate {

  public func createQuestionGroupTitleCell(_ cell: CreateQuestionGroupTitleCell,
                                           titleTextDidChange text: String) {
    // TODO: - Write this
    questionGroupBuilder.title = text
  }
}

//Chapter 9: Builser Pattern

//Tutorial project
//해당 리소스 파일을 drag-and-drop 할 때, Copy items if needed를 체크해 준다.
//CreateQuestionGroupViewController에서 새로운 QuestionGroup을 작성해 추가할 수 있도록 한다.
//main.storyboard 에서 해당 ViewController로 이동할 수 있게 설정해 줘야 한다.
//Bar Button Item을 추가하고, storyboard reference를 drag-and-drop해서 추가해 준다.
//해당 ViewController가 main.storyboard가 아닌 다른
//storyboard(NewQuestionGroup.storyboard)에 있으므로 참조가 필요하다.
//NewQuestionGroup.storyboard에서는
//CreateQuestionGroupViewController가 rootViewController로 설정되어 있다.
//CreateQuestionGroupViewController와 이를 호출하는 SelectQuestionGroupViewController에서
//필요한 코딩 작업을 해 준다(CreateQuestionGroupViewControllerDelegate 구현).

//Implementing the builder pattern
//CreateQuestionGroupViewController는 tableView를 사용해, QuestionGroup을 생성한다.
//여기서, CreateQuestionGroupViewController는 director 역할을 하고,
//QuestionGroup이 product가 된다.
//QuestionGroupBuilder.swift를 따로 생성해 Builder를 작성한다.
//이후 필요한 부분을 CreateQuestionGroupViewController에서 업데이트 해 준다.
