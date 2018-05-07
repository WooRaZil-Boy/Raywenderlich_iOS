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
import RealmSwift

#if EXAMS_V2_0

  class MigrateExamStatusViewController: UITableViewController {

    private var viewModel: MigrateExamsViewModel!
    private var didComplete: MigrationCompleted = nil

    static func createWith(storyboard: UIStoryboard = UIStoryboard(name: "Migrations", bundle: nil), didComplete: MigrationCompleted) -> MigrateExamStatusViewController {
      let vc = storyboard.instantiateViewController(withIdentifier: String(describing: MigrateExamStatusViewController.self)) as! MigrateExamStatusViewController
      vc.viewModel = MigrateExamsViewModel()
      vc.didComplete = didComplete
      return vc
    }

    private var examsToken: NotificationToken?
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      examsToken = viewModel.exams.observe { [weak self] _ in
        self?.updateUI()
      }
    }

    func updateUI() {
      UIView.transition(with: tableView, duration: 0.33, options: .transitionCrossDissolve, animations: {
        self.tableView.reloadData()
      }, completion: nil)
      if viewModel.exams.isEmpty {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(complete))
        navigationItem.rightBarButtonItem!.tintColor = .white
      }
    }

    override func viewDidDisappear(_ animated: Bool) {
      super.viewDidDisappear(animated)
      examsToken?.invalidate()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return viewModel.exams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let exam = viewModel.exams[indexPath.row]

      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MigrateExamStatusCell
      cell.update(with: exam, results: viewModel.results) {[weak self] newStatusIndex in
        guard let vm = self?.viewModel else { return }
        vm.updateExam(exam: exam, result: vm.results[newStatusIndex])
      }
      return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "Exams to update"
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
      return "During the last app update we found some exams without assigned status. Please tap on the status of each exam in the database. \n\nOnce you've cleared the list you can tap Done to start the app."
    }

    @objc func complete() {
      viewModel.completeMigration()
      didComplete?()
    }
}

#endif
