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
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class SplitViewController: UISplitViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let leftNavController = viewControllers.first as? UINavigationController,
      let masterViewController = leftNavController.viewControllers.first as? ContactListTableViewController,
      let detailViewController = (viewControllers.last as? UINavigationController)?.topViewController as? MessagesViewController else { fatalError()
    }
    //viewControllers 속성에서 master view controller와 detail view controller를 가져온다.
    
    let firstContact = masterViewController.contacts.first
    //기본적으로 split view controller는 첫번째 Contact를 표시한다.
    detailViewController.contact = firstContact
    masterViewController.delegate = detailViewController //delegate 설정
    detailViewController.navigationItem.leftItemsSupplementBackButton = true
    detailViewController.navigationItem.leftBarButtonItem = displayModeButtonItem
    //button을 설정해 준다. iPad에서 사용한다.
  }
}

//The split view controller
//split view controller를 추가하고, master view controller와 detail view controller를 설정해 준다.
//이후 Cocoa Touch Class로 SplitViewController를 생성한다.
//보통 아이폰등의 작은 화면에서는 기본적으로 split view controller는 detail view controller를 보여준다.
//그리고 뒤로 단추를 누르면, masterViewController가 보여진다.
//아이패드로 시뮬레이터를 바꿔 실행해 제대로 구현됐는지 확인해 본다.
