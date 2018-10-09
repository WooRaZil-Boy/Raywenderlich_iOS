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

class ListTableViewController: UITableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ShowGeotification" {
      guard let addViewController = segue.destination as? AddGeotificationViewController,
        let cell = sender as? UITableViewCell,
        let indexPath = tableView.indexPath(for: cell) else { return }
      
      addViewController.geotification = GeotificationManager.shared.geotifications[indexPath.row]
      addViewController.delegate = self
      
      addViewController.preferredContentSize = CGSize(width: 0, height: 360)
      //StoryBoard로 지정한 3D Touch Peeking 시의 크기를 지정해 준다.
      //preview는 default로 디바이스 전체를 채운다. 전체 표시될 경우, 공백이 있으므로 preferredContentSize를 조절해 준다.
      //preferredContentSize의 값은 주로 popover되는 ViewController의 내용을 표시할 때 크기를 지정해 주기 위해 사용된다.
    }
  }
}

// MARK: - Table view data source
extension ListTableViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return GeotificationManager.shared.geotifications.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GeotificationCell", for: indexPath)
    let geotification = GeotificationManager.shared.geotifications[indexPath.row]
    cell.textLabel?.text = geotification.title
    cell.detailTextLabel?.text = geotification.subtitle
    return cell
  }
}

// MARK: - Table View Delegate
extension ListTableViewController {
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard indexPath.row < GeotificationManager.shared.geotifications.count else { return }
    if editingStyle == .delete {
      tableView.beginUpdates()
      GeotificationManager.shared.remove(GeotificationManager.shared.geotifications[indexPath.row])
      tableView.deleteRows(at: [indexPath], with: .fade)
      tableView.endUpdates()
    }
  }
}

// MARK: - AddGeotificationsViewControllerDelegate

extension ListTableViewController: AddGeotificationsViewControllerDelegate {
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didAdd geotification: Geotification) {}
  
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didChange oldGeotifcation: Geotification, to newGeotification: Geotification) {
    navigationController?.popViewController(animated: true)
    GeotificationManager.shared.remove(oldGeotifcation)
    GeotificationManager.shared.add(newGeotification)
  }
  
  func addGeotificationViewController(_ controller: AddGeotificationViewController,
                                      didSelect action: UIPreviewAction,
                                      for previewedController: UIViewController) {
    //Preview의 Action을 처리한다.
    switch action.title {
    case "Edit":
      navigationController?.show(previewedController, sender: nil)
    case "Delete":
      guard let addGeotificationViewController = previewedController
        as? AddGeotificationViewController,
        let geotification = addGeotificationViewController.geotification else { return }
      GeotificationManager.shared.remove(geotification)
      tableView.reloadData()
    default:
      break
    }
  }
}

