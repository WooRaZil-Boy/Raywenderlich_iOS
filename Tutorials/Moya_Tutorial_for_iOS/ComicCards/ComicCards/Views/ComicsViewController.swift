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

import Foundation
import UIKit
import Moya

class ComicsViewController: UIViewController {
  let provider = MoyaProvider<Marvel>()
  //Moya의 Target과 상호작용할 때, 기본적으로 MoyaProvider 클래스를 사용한다.
  
  // MARK: - View State
  private var state: State = .loading {
    didSet {
      switch state {
      case .ready:
        viewMessage.isHidden = true
        tblComics.isHidden = false
        tblComics.reloadData()
      case .loading:
        tblComics.isHidden = true
        viewMessage.isHidden = false
        lblMessage.text = "Getting comics ..."
        imgMeessage.image = #imageLiteral(resourceName: "Loading")
      case .error:
        tblComics.isHidden = true
        viewMessage.isHidden = false
        lblMessage.text = """
                            Something went wrong!
                            Try again later.
                          """
        imgMeessage.image = #imageLiteral(resourceName: "Error")
      }
    }
  }

  // MARK: - Outlets
  @IBOutlet weak private var tblComics: UITableView!
  @IBOutlet weak private var viewMessage: UIView!
  @IBOutlet weak private var lblMessage: UILabel!
  @IBOutlet weak private var imgMeessage: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()

    state = .loading //뷰의 상태를 .loading으로 설정
    
    provider.request(.comics) { [weak self] result in
      //provider를 사용해서 .comics의 endPoint에서 request 수행
      //.comics이 enum의 case이므로, 이것은 완전히 type-safe 하다(Moya의 장점).
      guard let self = self else { return }
      
      switch result { //클로저의 result는 .success(Moya.Response)나 .failure(Error)가 될 수 있다.
      case .success(let response): //request 성공
        do {
//          print(try response.mapJSON()) //JSON형태 매핑
          self.state = .ready(try response.map(MarvelResponse<Comic>.self).data.results)
          //뷰 컨트롤러를 완성하려면 JSON request를 적절한 데이터 모델에 매핑해야 한다(여기서는 Comic 구조체).
          //raw JSON data를 Decodable을 구현한 Comic 구조체로 매핑한다.
          //이전 JSON에서는 중첩적인 data 안에 result가 있는 구조로 되어 있었지만,
          //해당 객체에서는 data.results로 접근 가능하다(객체 구조 확인해 볼 것).
          
          //에러 없이 제대로 객체를 가져오면 state가 .ready가 되면서 tableView가 reload 된다.
        } catch { //변환시 예외가 발생하면 error 설정
          self.state = .error
        }
      case .failure: //request 실패
        self.state = .error
      }
    }
  }
}

extension ComicsViewController {
  enum State {
    case loading
    case ready([Comic])
    case error
  }
}

// MARK: - UITableView Delegate & Data Source
extension ComicsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ComicCell.reuseIdentifier, for: indexPath) as? ComicCell ?? ComicCell()

    guard case .ready(let items) = state else { return cell }

    cell.configureWith(items[indexPath.item])

    return cell
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard case .ready(let items) = state else { return 0 }

    return items.count
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    guard case .ready(let items) = state else { return }

    let comicVC = CardViewController.instantiate(comic: items[indexPath.item])
    navigationController?.pushViewController(comicVC, animated: true)
  }
}

//State enum의 case를 사용해 (ready의 [Comic]) 테이블 뷰를 설정한다.

