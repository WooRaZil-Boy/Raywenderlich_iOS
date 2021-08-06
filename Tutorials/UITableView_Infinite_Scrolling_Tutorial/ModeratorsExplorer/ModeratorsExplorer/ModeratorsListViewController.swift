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

class ModeratorsListViewController: UIViewController, AlertDisplayer {
  private enum CellIdentifiers {
    static let list = "List"
  }
  
  @IBOutlet var indicatorView: UIActivityIndicatorView!
  @IBOutlet var tableView: UITableView!
  
  var site: String!
  
  private var viewModel: ModeratorsViewModel!
  
  private var shouldShowLoadingCell = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    indicatorView.color = ColorPalette.RWGreen
    indicatorView.startAnimating()
    
    tableView.isHidden = true
    tableView.separatorColor = ColorPalette.RWGreen
    tableView.dataSource = self
    tableView.prefetchDataSource = self
    //prefetchDataSource를 설정해 준다.
    
    let request = ModeratorRequest.from(site: site)
    viewModel = ModeratorsViewModel(request: request, delegate: self)
    
    viewModel.fetchModerators()    
  }
}

extension ModeratorsListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return viewModel.currentCount
    return viewModel.totalCount
    //list가 아직 complete되지 않은 경우에도 table view에서 예상되는 모든 moderators에 대한 row을 표시할 수 있도록
    //이미 받은 moderators 수를 반환하는 대신, 서버에서 사용 가능한 총 moderators 수를 반환한다.
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.list, for: indexPath) as! ModeratorTableViewCell
//    cell.configure(with: viewModel.moderator(at: indexPath.row))
    
    if isLoadingCell(for: indexPath) {
      cell.configure(with: .none)
      //current cell에 대한 moderator를 받지 못한 경우, empty value으로 cell을 configure한다.
      //이 경우 cell은 spinning indicator view를 표시한다.
    } else {
      cell.configure(with: viewModel.moderator(at: indexPath.row))
      //moderator가 이미 목록에 있는 경우, cell에 전달하여 name과 reputation를 표시한다.
    }
    
    return cell
  }
}

extension ModeratorsListViewController: ModeratorsViewModelDelegate {
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?) {
//    indicatorView.stopAnimating()
//    tableView.isHidden = false
//    tableView.reloadData()
    
    guard let newIndexPathsToReload = newIndexPathsToReload else {
      //newIndexPathsToReload가 nil(첫 page)이면 indicator view를 숨기고 table view를 표시한 후 reload한다.
      indicatorView.stopAnimating()
      tableView.isHidden = false
      tableView.reloadData()
      return
    }

    
    let indexPathsToReload = visibleIndexPathsToReload(intersecting: newIndexPathsToReload)
    tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    //newIndexPathsToReload가 nil이 아닌 경우(다음 page), reload해야 하는 visible cells을 찾아 table view에 해당 cells만 reloading하도록 한다.
  }
  
  func onFetchFailed(with reason: String) {
    indicatorView.stopAnimating()
    
    let title = "Warning".localizedString
    let action = UIAlertAction(title: "OK".localizedString, style: .default)
    displayAlert(with: title , message: reason, actions: [action])
  }
}

extension ModeratorsListViewController: UITableViewDataSourcePrefetching {
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    if indexPaths.contains(where: isLoadingCell) {
      viewModel.fetchModerators()
    }
  }
}

private extension ModeratorsListViewController {
  //Helper Methods
  func isLoadingCell(for indexPath: IndexPath) -> Bool {
    //해당 indexPath의 cell이 지금까지 수신한 moderators 수를 초과하는지 여부를 결정한다.
    return indexPath.row >= viewModel.currentCount
  }

  func visibleIndexPathsToReload(intersecting indexPaths: [IndexPath]) -> [IndexPath] {
    //새 page를 받을 때 reload해야 하는 table view의 cells을 계산한다.
    //view model이 전달한 IndexPaths와 현재 보이는 IndexPaths의 intersection을 계산한다.
    //현재 화면에 표시되지 않는 cell을 refreshing하지 않으려면 이를 사용한다.
    let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows ?? []
    let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
    return Array(indexPathsIntersection)
  }
}
