/// Copyright (c) 2020 Razeware LLC
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
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class RepositoriesViewController: UITableViewController {
  var repositories: [Repository] = []
  var selectedRepository: Repository?
  let loadingIndicator = UIActivityIndicatorView(style: .large)
  var isLoggedIn: Bool {
    if TokenManager.shared.fetchAccessToken() != nil {
      return true
    }
    return false
  }

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var loginButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    loadingIndicator.center = view.center
    view.addSubview(loadingIndicator)
//    loginButton.isHidden = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //Avoid reloading repositories if active search is in place
    if let searchText = searchBar.text, !searchText.isEmpty {
      return
    }
    if isLoggedIn {
      loginButton.setTitle("Logout", for: .normal)
      fetchAndDisplayUserRepositories()
    } else {
      loginButton.setTitle("Login", for: .normal)
      fetchAndDisplayPopularSwiftRepositories()
    }
  }

  func fetchAndDisplayPopularSwiftRepositories() {
    loadingIndicator.startAnimating()
    GitAPIManager.shared.fetchPopularSwiftRepositories { repositories in
      self.repositories = repositories
      self.loadingIndicator.stopAnimating()
      self.tableView.reloadData()
    }
  }

  func fetchAndDisplayUserRepositories() {
    //TODO: Add more here..
    loadingIndicator.startAnimating()
    //network request을 하기 전에 loading indicator를 표시한다.
    GitAPIManager.shared.fetchUserRepositories { [self] repositories in
      //network reques을 수행해 repositories를 가져온다.
      self.repositories = repositories //repositories 설정
      loadingIndicator.stopAnimating() //loading indicator 해제
      tableView.reloadData() //table view를 reload하여 repositories를 표시한다.
    }
  }

  func logout() {
    TokenManager.shared.clearAccessToken()
    loginButton.setTitle("Login", for: .normal)
    fetchAndDisplayPopularSwiftRepositories()
  }
}

// MARK: - UITableViewDataSource
extension RepositoriesViewController {
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repositories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath)
    cell.textLabel?.text = repositories[indexPath.row].name
    cell.detailTextLabel?.text = repositories[indexPath.row].description
    return cell
  }
}

// MARK: - UITableViewDeletage
extension RepositoriesViewController {
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedRepository = repositories[indexPath.row]
    return indexPath
  }
}

// MARK: - Handling Segue
extension RepositoriesViewController {
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "LoginSegue" {
      let shouldProceed = !isLoggedIn
      if isLoggedIn {
        //logout button pressed
        logout()
      }
      return shouldProceed
    }
    return true
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "CommitSegue" {
      guard let commitsViewController = segue.destination as? RepositoryCommitsViewController else {
        return
      }
      commitsViewController.selectedRepository = selectedRepository
    }
  }
}

// MARK: - UISearchBarDelegate
extension RepositoriesViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = searchBar.text else {
      return
    }
    loadingIndicator.startAnimating()
    GitAPIManager.shared.searchRepositories(query: query) { repositories in
      self.repositories = repositories
      self.loadingIndicator.stopAnimating()
      self.tableView.reloadData()
    }
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    if isLoggedIn {
      fetchAndDisplayUserRepositories()
    } else {
      fetchAndDisplayPopularSwiftRepositories()
    }
  }
}
