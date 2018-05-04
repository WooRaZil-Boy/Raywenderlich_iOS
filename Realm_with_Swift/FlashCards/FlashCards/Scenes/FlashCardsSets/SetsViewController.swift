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

class SetsViewController: UITableViewController {

  private var viewModel: SetsViewModel!
  private var api = CardsAPI()

  // MARK: - ViewController life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel = SetsViewModel(api: api)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.didUpdate = { [weak self] deleted, inserted, updated in
      self?.tableView.applyChanges(deletions: deleted, insertions: inserted, updates: updated)
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.didUpdate = nil
  }

  // MARK: - Table DataSource

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.sets.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SetTableViewCell ?? SetTableViewCell()
    let set = viewModel.sets[indexPath.row]

    cell.configureWith(set)
    return cell
  }

  // MARK: - Table Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)

    let set = viewModel.sets[indexPath.row]

    if set.isAvailable {
      // Display set if available
      let cardVC = CardsViewController.createWith(storyboard!, viewModel: CardsViewModel(set: set))
      navigationController!.pushViewController(cardVC, animated: true)

    } else {
      // Otherwise, download
      let setName = set.name
      let cell = tableView.cellForRow(at: indexPath) as! SetTableViewCell

      UIAlertController.confirm("Do you want to download the card set '\(setName)'?") { [weak self] confirmed in
        guard confirmed else { return }

        cell.isLoading = true

        self?.viewModel.downloadSet(named: setName) { _ in
          cell.isLoading = false
        }
      }
    }
  }
}
