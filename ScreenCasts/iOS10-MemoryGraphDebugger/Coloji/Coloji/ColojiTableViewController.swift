/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit



class ColojiTableViewController: UITableViewController {
    
  let colors = [UIColor.gray, UIColor.green, UIColor.yellow, UIColor.brown, UIColor.cyan, UIColor.purple]
  let emoji = ["💄", "🙋🏻", "👠", "🎒", "🏩", "🎏"]
  let colojiStore = ColojiDataStore()
  
  let queue = DispatchQueue(label: "com.raywenderlich.coloji.data-load", attributes: .concurrent, target: .none)
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
  }

  // MARK: - Table view data source
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return colojiStore.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "colojiCell", for: indexPath)
    
    let coloji = colojiStore.colojiAt(index: indexPath.row)
    
    let cellFormatter = ColojiCellFormatter(coloji: coloji)
    cellFormatter.configureCell(cell)
    
    return cell
  }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? ColojiViewController,
      let selectedIndex = tableView.indexPathForSelectedRow
    {
      destVC.coloji = colojiStore.colojiAt(index: selectedIndex.row)
    }
  }
  
}


extension ColojiTableViewController {
  func loadData() {
    let group = DispatchGroup()
    
    for color in colors {
      group.enter()
      queue.async {
        let coloji = createColoji(color: color)
        self.colojiStore.append(coloji: coloji)
        group.leave()
      }
    }

    for emoji in emoji {
      group.enter()
      queue.async {
        let coloji = createColoji(emoji: emoji)
        self.colojiStore.append(coloji: coloji)
        group.leave()
      }
    }
    
    group.notify(queue: DispatchQueue.main) { 
      self.tableView.reloadData()
    }
  }
}

//Debug Navigator 에서 메모리와 CPU 사용량을 체크해 볼 수 있다. //retain cycle이 생기면, 메모리가 제대로 해제되지 않고 낭비된다.
//콘솔창 메뉴의 Memory graph debugger를 사용하면, 메모리 그래프를 캡쳐해 확인할 수 있다.
//그러면 running 메시지 창에서 문제가 있는 부분에 대한 느낌표 모양의 보라색 아이콘을 확인할 수 있다.
//그래프의 모양을 확인하면, retain cycle된 객체들을 확인해 볼 수 있다.
//스키마를 추가해 메모리를 barcktrace할 수 있다.
//Edit Scheme - Run - Diagnostics 에서 Malloc Stack을 체크한다(Live Allocations Only).
//다시 빌드 실행한 후, Memory graph debugger에서 객체를 클릭하면, Backtrace에서 객체 유형과 타입을 확인할 수 있다.

//이 외에도 Memory graph debugger로 중복되는 객체를 찾아내는 등에 활용할 수 있다.


