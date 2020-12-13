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
import Alamofire

class MainTableViewController: UITableViewController {
  var items: [Displayable] = []
  var films: [Film] = []

  var selectedItem: Displayable?

  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    
    fetchFilms()
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
    let item = items[indexPath.row]
    cell.textLabel?.text = item.titleLabelText
    cell.detailTextLabel?.text = item.subtitleLabelText

    return cell
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedItem = items[indexPath.row]
    return indexPath
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destinationVC = segue.destination as? DetailViewController else {
      return
    }
    destinationVC.data = selectedItem
  }
}

// MARK: - UISearchBarDelegate
extension MainTableViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let shipName = searchBar.text else { return }
    searchStarships(for: shipName)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder()
    items = films
    tableView.reloadData()
  }
}

extension MainTableViewController {
  func fetchFilms() {
//    let request = AF.request("https://swapi.dev/api/films")
//    //Alamofire는 namespacing을 사용하기 때문에, AF와 함께 사용하는 모든 호출에 prefix를 지정해야 한다.
//    //request(_:method:parameters:encoding:headers:interceptor:)는 데이터에 대한 end point를 허용한다.
//    //더 많은 parameters를 사용할 수 있지만 지금은 URL을 문자열로 보내고, 기본 parameter 값을 사용한다.
//
////    request.responseJSON { (data) in
////      //request에서 받은 response를 JSON으로 가져온다.
////      print(data)
////      //지금은 단순 디버깅을 위해 JSON 데이터를 출력한다.
////    }
//
//    request.responseDecodable(of: Films.self) { (response) in
//      guard let films = response.value else { return }
//      print(films.all[0].title)
//    }
    
    //Method Chaining
    AF.request("https://swapi.dev/api/films")
      .validate()
      .responseDecodable(of: Films.self) { (response) in
        guard let films = response.value else { return }
        self.films = films.all //cache
//        print(films.all[0].title)
        self.items = films.all
        self.tableView.reloadData()

      }
  }
  
  func searchStarships(for name: String) {
    let url = "https://swapi.dev/api/starships"
    //starship 데이터에 access하는 데 사용할 URL을 설정한다.
    let parameters: [String: String] = ["search": name]
    //endpoint로 보낼 key-value parameters를 설정한다.
    AF.request(url, parameters: parameters)
      //이전과 같은 request이지만, parameters를 추가했다.
      .validate() //validate
      .responseDecodable(of: Starships.self) { response in //decoding
        //request가 completes되면,
        guard let starships = response.value else { return }
        self.items = starships.all //starships 목록을 tableView의 데이터로 할당하고
        self.tableView.reloadData() //tableView를 다시 로드한다.
      }
  }
}
