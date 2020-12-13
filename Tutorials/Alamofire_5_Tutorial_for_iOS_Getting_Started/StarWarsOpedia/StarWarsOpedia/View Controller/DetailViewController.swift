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

class DetailViewController: UIViewController {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var item1TitleLabel: UILabel!
  @IBOutlet weak var item1Label: UILabel!
  @IBOutlet weak var item2TitleLabel: UILabel!
  @IBOutlet weak var item2Label: UILabel!
  @IBOutlet weak var item3TitleLabel: UILabel!
  @IBOutlet weak var item3Label: UILabel!
  @IBOutlet weak var listTitleLabel: UILabel!
  @IBOutlet weak var listTableView: UITableView!
  
  var data: Displayable?
  var listData: [Displayable] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    commonInit()
    
    listTableView.dataSource = self
    fetchList()
  }
  
  private func commonInit() {
    guard let data = data else { return }
    
    titleLabel.text = data.titleLabelText
    subtitleLabel.text = data.subtitleLabelText
    
    item1TitleLabel.text = data.item1.label
    item1Label.text = data.item1.value
    
    item2TitleLabel.text = data.item2.label
    item2Label.text = data.item2.value
    
    item3TitleLabel.text = data.item3.label
    item3Label.text = data.item3.value
    
    listTitleLabel.text = data.listTitle
  }
}

// MARK: - UITableViewDataSource
extension DetailViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
    cell.textLabel?.text = listData[indexPath.row].titleLabelText
    
    return cell
  }
}

extension DetailViewController {
  private func fetch<T: Decodable & Displayable>(_ list: [String], of: T.Type) {
    //Starship은 films 목록을 가지고 있다. Film과 Starship은 모두 Displayable이므로,
    //네트워크 request를 수행하기 위한 generic heper를 작성할 수 있다.
    //결과를 적절하게 decode 할수 있도록, 가져 오는 항목의 type만 알면 된다.
    var items: [T] = []
    let fetchGroup = DispatchGroup()
    //item당 multiple calls이 필요하며, 이러한 call은 asynchronous이므로 순서가 맞지 않을 수 있다.
    //이를 처리하기 위해, 모든 calls이 completed되면 통지 받을 수 있도록 dispatch group을 사용한다.
    
    list.forEach { (url) in
      //list의 item을 반복한다.
      fetchGroup.enter()
      //dispatch group에 enter를 알려준다.
      
      AF.request(url) //starship 엔드 포인트(end point)에 Alamofire request하고
        .validate() //response를 validate 한 후
        .responseDecodable(of: T.self) { (response) in
          //적절한 type으로 decode한다.
          if let value = response.value {
            items.append(value)
          }
          
          fetchGroup.leave()
          //request의 completion handler에서 dispatch group에 leave를 알려준다.
      }
    }
    
    fetchGroup.notify(queue: .main) {
      //dispatch group이 각 enter()에 대해 leave()를 받으면, main queue에서 실행 중인지 확인하고
      self.listData = items //listData에 저장한 후
      self.listTableView.reloadData() //list table view를 reload한다.
    }
  }
  
  func fetchList() {
    guard let data = data else { return }
    //data는 optional이므로, 다른 작업을 수행하기 전에 nil이 아닌지 확인한다.
    
    switch data { //data를 사용하여 helper method를 호출하는 방법을 결정한다.
    case is Film:
      //data가 Film인 경우, 관련 목록은 starships의 list이다.
      fetch(data.listItems, of: Starship.self)
    case is Starship:
      //data가 Starship인 경우, 관련 목록은 Film의 list이다.
      fetch(data.listItems, of: Film.self)
    default:
      print("Unknown type: ", String(describing: type(of: data)))
    }
  }
}



