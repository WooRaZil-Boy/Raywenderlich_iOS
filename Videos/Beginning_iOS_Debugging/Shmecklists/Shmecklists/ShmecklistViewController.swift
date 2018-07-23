/**
 * Copyright (c) 2018 Razeware LLC
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
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
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

class ShmecklistViewController: UITableViewController, ItemDetailViewControllerDelegate {
  
  func addItemViewControllerDidCancel(_ controller: ItemDetailV) {
    navigationController?.popViewController(animated: true)
  }
  
  func addItemViewController(_ controller: ItemDetailV, didFinishEditing item: ShmecklistItem) {
    
    if let index = items.index(of: item) {
      let indexPath = IndexPath(row: index, section:0)
      if let cell = tableView.cellForRow(at: indexPath) {
        configureText(for: cell, with: item)
      }
    }
    navigationController?.popViewController(animated: true)
  }
  
  func addItemViewController(_ controller: ItemDetailV, didFinishAdding item: ShmecklistItem) {
    let newRowIndex = items.count
    items.append(item)
    
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    let indexPaths = [indexPath]
    tableView.insertRows(at: indexPaths, with: .automatic)
    navigationController?.popViewController(animated: true)
  }
  
  var items: [ShmecklistItem]
  
  @IBAction func addItem(_ sender: Any) {
    let newRowIndex = items.count
    
    let item = ShmecklistItem()
    var titles = ["Empty todo item", "Generic todo", "First todo: fill me out", "I need something to do", "Much todo about nothing"]
    let randomNumber = arc4random_uniform(UInt32(titles.count))
    let title = titles[Int(randomNumber)]
    item.text = title
    item.checked = true
    items.append(item)
    
    let indexPath = IndexPath(row: newRowIndex, section: 0)
    let indexPaths = [indexPath]
    tableView.insertRows(at: indexPaths, with: .automatic)
  }
  
  required init?(coder aDecoder: NSCoder) {
    
    items = [ShmecklistItem]()
    
    let row0Item = ShmecklistItem()
    row0Item.text = "Walk the dog"
    row0Item.checked = false
    items.append(row0Item)
    
    let row1Item = ShmecklistItem()
    row1Item.text = "Brush my teeth"
    row1Item.checked = false
    items.append(row1Item)
    
    let row2Item = ShmecklistItem()
    row2Item.text = "Learn iOS development"
    row2Item.checked = false
    items.append(row2Item)
    
    let row3Item = ShmecklistItem()
    row3Item.text = "Soccer pratice"
    row3Item.checked = false
    items.append(row3Item)
    
    let row4Item = ShmecklistItem()
    row4Item.text = "Eat ice cream"
    row4Item.checked = true
    items.append(row4Item)
    
    let row5Item = ShmecklistItem()
    row5Item.text = "Watch Game of Thrones"
    row5Item.checked = true
    items.append(row5Item)
    
    let row6Item = ShmecklistItem()
    row6Item.text = "Read iOS Apprentice"
    row6Item.checked = true
    items.append(row6Item)
    
    let row7Item = ShmecklistItem()
    row7Item.text = "Take a nap"
    row7Item.checked = false
    items.append(row7Item)
    
    super.init(coder: aDecoder)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "AddItem" {
      let controller = segue.destination as! ItemDetailV
      controller.delegate = self
    } else if segue.identifier == "EditItem" {
      let controller = segue.destination as! ItemDetailV
      controller.delegate = self
      if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
        controller.itemToEdit = items[indexPath.row]
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    navigationController?.navigationBar.prefersLargeTitles = true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    
    items.remove(at: indexPath.row)
    
    let indexPaths = [indexPath]
    tableView.deleteRows(at: indexPaths, with: .automatic)
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let cell = tableView.cellForRow(at: indexPath) {
      let item = items[indexPath.row]
      item.toggleChecked()
      configureCheckmark(for: cell, with: item)
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "ShmecklistItem", for: indexPath)
    let item = items[indexPath.row]
    
    configureText(for: cell, with: item)
    configureCheckmark(for: cell, with: item)
    return cell
  }
  
  func configureText(for cell: UITableViewCell, with item: ShmecklistItem) {
    let label = cell.viewWithTag(1000) as! UILabel
    label.text = item.text
  }
  
  func configureCheckmark(for cell: UITableViewCell, with item: ShmecklistItem) {
    
    let label = cell.viewWithTag(1001) as! UILabel
    
    if item.checked {
      label.text = "√"
    } else {
      label.text = ""
    }
  }
}

//2. Breakpoints
//line num의 위치를 단순히 클릭하거나, ⌘ + \ 으로 해당 line에 break point를 설정할 수 있다.
//실행 시 멈춘 이후에 단순히 하단 콘솔 창의 continue 버튼을 눌러 계속 진행할 수 있다.
//좌측 패널에서 Break point navigator를 클릭해 모든 break point를 확인할 수 있다.




//3. Controlling Breakpoints
//여러 개의 break point들을 설정한 경우에는, continue 버튼을 누르면, 다음 break point까지 진행한 후 다시 멈춘다.
//for 나 delegate의 cellForRowAt 처럼 반복되는 부분에 break point를 설정한 경우에는 반복 횟수만큼 호출된다.
//break point를 건너 뛰고 싶을 경우에는 해당 break point를 num line에서 클릭하면 희미한 파란색이 되면서 해제된다.
//모든 break point를 전체 해제해야 하는 경우에는 콘솔창의 Deactivate breakpoints를 클릭해 주면 된다(삭제 아닌 일시 해제).
//좌측 패널의 Break point navigator에서도 확인하거나 각각을 해제 / 재설정 해 줄 수 있다.
//더 이상 break point가 필요하지 않은 경우에는 num line에서 드래그 앤 드랍으로 삭제하거나,
//Break point navigator에서 delete 버튼으로 삭제할 수 있다.




//4. Inspecting Variables
//break point에 멈춘 상태에서 콘솔의 왼쪽 창(debug area)을 확인하여 해당 시점의 정보를 확인할 수 있다.
//코드 영역이 끝나는 부분(})에 break point를 설정해, 설정된 이후의 값을 확인할 수 있다.
//하지만 UIView처럼 많은 정보를 가지고 있는 객체의 정보를 일일히 확인해 보기는 어렵다.
//이런 경우 해당 객체를 선택한 후, debug area 최하단의 ⓘ 을 클릭하면 우측 콘솔에 해당 객체의 정보가 출력된다.
//(lldb) 가 활성화된 콘솔에서 po label(객체) 를 입력해도 같은 결과가 출력된다. po는 Print Object의 약자이다.
//여기서 출력되는 속성들을 출력할 수도 있다. ex. po label.text! (lldb 콘솔 창에서도 input assistant가 된다)
//(lldb) 에서 해당 속성의 값을 변경할 수도 있다(크롬 개발자 도구 처럼). ex. po label.text = "Buggy item"
//디버깅 시 method chaining을 길게 하면, 버그를 찾기 어려운 경우가 많다.
//ex. process(item: getNextItem()) 보다

//let nextItem = getNextItem()
//process(item: nextItem) 으로 풀어서 쓰는 것이 디버깅 하기 수월하다.




//6. Control Flow
//break point 위치를 정확히 지정했더라도, 다른 부분의 코드에서 버그가 발생한 경우 이를 제대로 잡아내기 힘들다.
//이런 경우, debug area의 Step into, Step out, Step over 버튼를 눌러 Flow를 추적할 수 있다.
//Step Over(F6) : 현재 디버깅 라인을 한줄 한줄 내려간다.
//Step Into(F7) : Step Over와 같지만 함수(메소드, 메세지)를 만나면 해당 함수로 점프한다.
//Step Out(F8) : 현재 함수를 빠져 나온다(메세지를 호출한 쪽으로 점프).
//http://lucy092.tistory.com/5

//debug area의 continue 버튼은 앱을 새로 빌드하지 않는다. 따라서 버그를 찾아 고쳤다 하더라도, 바로 적용되지 않는다.
//새로 적용된 코드로 앱을 실행하려면 build를 새로 해야 한다.
//break point를 지정하지 않았다고 하더라도, 다른 break에 멈춰 있는 상태에서 해당 line에서 우 클릭 - Continue to Here을
//선택하면, 그 위치의 코드에서 break가 된다.




//7. Call Stack
//좌측 패널의 Debug navigator에서 Stack을 볼 수 있다.
//Stack에는 method가 호출 될 때마다 쌓이며, state와 parameter도 함께 쌓인다.
//이전의 Step Into와 Step Out은 Stack에서 한 단계씩 움직이는 것이다.
//실제로 Step Into를 클릭하면, Debug navigator에서 Stack이 하나 push되며,
//Step Out을 클릭하면, Debug navigator에서 Stack이 하나 pop 된다.
//Stack은 state와 parameter도 저장하고 있기 때문에, 해당 stack을 선택해, 상세 정보를 확인해 볼 수 있다(po, ⓘ ..).
//좌측 패널 하단의 Filter를 통해 더 자세히 볼 수 있다(첫 번째 버튼).




//8. View Hierarchy
//Storyboard에서 Debug View Hierachy를 눌러 뷰의 계층 구조를 파악할 수 있다.
//View Hierarchy에서 size inspector로 frame을 확인해 볼 수도 있다.

