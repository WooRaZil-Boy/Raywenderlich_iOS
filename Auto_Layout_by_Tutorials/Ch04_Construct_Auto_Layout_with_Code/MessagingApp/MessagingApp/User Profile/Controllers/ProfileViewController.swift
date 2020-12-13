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

final class ProfileViewController: UIViewController {
  private let profileHeaderView = ProfileHeaderView() //추가
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    setupProfileHeaderView()
  }
  
  private func setupProfileHeaderView() {
    view.addSubview(profileHeaderView) //HeaderView 추가
    
    profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
    //Interface Builder에서 작성한 대로 Auto layout이 작동하려면 항상 false를 설정해야 한다.
    //기본값은 true이다. Autoresizing mask는 Auto Layout 이전에 사용하던 방식이다.
    //Auto Layout과 비교하면, 더 포괄적인 layout 시스템이다.
    
//    profileHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//    profileHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//    profileHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//    profileHeaderView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    //각 앵커를 설정하고, 활성화한다.
    
    //위의 코드를 아래와 같이 리펙토링할 수 있다.
    NSLayoutConstraint.activate([
        profileHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        profileHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        profileHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        profileHeaderView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
    //이 방식이 좀 더 가독성이 좋고 성능도 우수하다.
    
  }
}

//Launching a view controller without initializing storyboard

//Profile.storyboard와 TabBar.storyboard를 삭제한다.
//이어서 ProfileViewController의 Outlet을 삭제해준다.
//AppDelegate.swift에서 코드를 수정해 준다.




//Setting up profile header view


