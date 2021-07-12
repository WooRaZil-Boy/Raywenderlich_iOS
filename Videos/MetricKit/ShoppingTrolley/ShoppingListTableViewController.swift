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
import MetricKit

class ShoppingListTableViewController: UITableViewController {

  let fruit = ["🍏 Apples", "🍌 Bananas", "🍓 Strawberries"]

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let metricManager = MXMetricManager.shared //singleton
    metricManager.add(self)
    //subscriber(self)를 지정해 준다.
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = fruit[indexPath.row]
    return cell
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fruit.count
  }
}

extension ShoppingListTableViewController: MXMetricManagerSubscriber {
  //MXMetricManagerSubscriber를 구현해 준다.
  func didReceive(_ payloads: [MXMetricPayload]) {
    guard let firstPayload = payloads.first else { return }
//    print(firstPayload.dictionaryRepresentation())
    //key-value dictionary를 모두 출력한다.
    
    let latestApplicationVersion = firstPayload.latestApplicationVersion
    let peakMemoryUsage = "\(firstPayload.memoryMetrics?.peakMemoryUsage.value ?? 0.00)"
    let cumulativeBackgroundTime = "\(firstPayload.applicationTimeMetrics?.cumulativeBackgroundTime.value ?? 0.00)"
    //payload에서 필요한 값을 가져온다.
    
    let parameters = [
      "latestApplicationVersion": latestApplicationVersion,
      "peakMemoryUsage": peakMemoryUsage,
      "cumulativeBackgroundTime": cumulativeBackgroundTime
    ]
    let postData = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted])
    
    //API 호출
    let session = URLSession.shared
    guard let url = URL(string: "http://localhost:8080/info") else { return }
    //하지만, 실제 iOS 기기에서 localhost를 사용할 수 없으므로, 테스트 용이라도 이를 수정해야 한다.
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = postData
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTask(with: request) { (data, response, error) in
      guard error == nil else {
        return
      }
      
      guard let data = data else {
        return
      }
      
      do {
        if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
          print(json)
        }
      } catch let error {
        print(error.localizedDescription)
      }
    }
    task.resume()
  }
}

//vapor가 설치되지 않았다면, terminal에서 brew install vapor를 입력하여 설치한다.
//해당 프로젝트 폴더에서 vapor new ShoppingTrolleyServer
//cd ShoppingTrolleyServer
//vapor xcode 를 입력해 해당 프로젝트를 Xcode에서 작업할 수 있다.
