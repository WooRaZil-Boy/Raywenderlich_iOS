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
  // MARK: - Properties
  private let profileHeaderView = ProfileHeaderView()
  private let mainStackView = UIStackView()
  private let scrollView = UIScrollView() //스크롤 뷰 추가
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    setupScrollView()
    setupMainStackView()
  }
  
  // MARK: - Layouts
  private func setupProfileHeaderView() {
    profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
    //코드로 auto layout을 적용해 주려면, false로 해 줘야 한다.
    
    profileHeaderView.heightAnchor.constraint(equalToConstant: 360).isActive = true
    mainStackView.addArrangedSubview(profileHeaderView) //스택 뷰에 추가한다.
    //StackView에 추가되므로, 보통과 같은 복잡한 제약조건을 추가할 필요가 없다.
    //스택 뷰를 사용하면, 뷰의 크기가 적절하게 조정된다.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  private func setupMainStackView() {
    mainStackView.axis = .vertical
    mainStackView.distribution = .equalSpacing
    mainStackView.translatesAutoresizingMaskIntoConstraints = false
    //코드로 auto layout을 적용해 주려면, false로 해 줘야 한다.

//    view.addSubview(mainStackView) //view에 추가한다.
//
//    let contentLayoutGuide = view.safeAreaLayoutGuide
//    NSLayoutConstraint.activate([
//      mainStackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
//      mainStackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
//      mainStackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor)
//    ]) //제약 조건을 추가한다. 아이폰 X등의 장치 여백에 지장을 주지 않도록 safeAreaLayoutGuide를 사용한다.
//    //stackView는 수직으로 확장되므로, 하단의 제약 조건을 추가할 필요는 없다.
//
//    setupProfileHeaderView()
//    setupButtons()
    
    
    
    //mainStackView를 scrollView 안에 넣어야 한다. 코드를 변경한다.
    scrollView.addSubview(mainStackView) //mainStackView를 scrollView에 추가한다.
    
    let contentLayoutGuide = scrollView.contentLayoutGuide
    //scroll view의 Content Layout Guide의 참조를 가져온다.
    //scroll view의 Content 영역을 나타낸다.
    NSLayoutConstraint.activate([
      mainStackView.widthAnchor.constraint(equalTo: view.widthAnchor),
      //스택 뷰의 너비는 view의 widthAnchor로 설정한다. scroll view가 내용의 크기를 차지하기 때문에
      //이렇게 설정하지 않으면, 스크롤 뷰가 축소된다.
      //또한, 이렇게 설정하면, 가로 스크롤이 비활성됨을 나타낸다.
      mainStackView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
      mainStackView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
      mainStackView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
      mainStackView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor)
      //이전과 달리, bottomAnchor를 추가해야 한다. 스크롤 뷰를 확장해 모든 뷰에 맞도록 한다.
    ]) //제약 조건을 추가한다.
    
    setupProfileHeaderView()
    setupButtons()
  }
  
  
  private func setupScrollView() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    //코드로 auto layout을 적용해 주려면, false로 해 줘야 한다.
    view.addSubview(scrollView)
    
    //Setting up the scroll view
//    NSLayoutConstraint.activate([
//      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//      scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//    ]) //스크롤 뷰의 제약조건을 설정한다.
//    //스크롤 뷰 계층 구조를 벗어난 view와의 제약조건을 추가해야 하기 때문에 스크롤뷰의 frame을 설정한다.
    
    
    
    
    //Using the Frame Layout Guide
    //스크롤 뷰를 리펙토링할 수 있다.
    let frameLayoutGuide = scrollView.frameLayoutGuide
    //이 레이아웃은 스크롤 뷰의 콘텐츠가 아닌, 스크롤 뷰 자체의 프레임을 가리킨다.
    NSLayoutConstraint.activate([
      frameLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      frameLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      frameLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      frameLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
      //leadingAnchor과 trailingAnchor의 경우에는 view를 제약조건으로 한다.
      //이렇게 하면 스크롤 뷰는 화면 전체 너비를 차지하게 된다.
    ]) //제약조건을 추가한다.
    //변한 것이 없어 보이지만, Frame Layout Guide를 사용하면 더 정확하고 가독성이 좋아진다.
  }
}

// MARK: - Buttons Configuration
extension ProfileViewController {
  private func createButton(text: String, color: UIColor = .blue) -> UIButton {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.heightAnchor.constraint(equalToConstant: 55).isActive = true
    button.setTitle(text, for: .normal)
    button.setTitleColor(color, for: .normal)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 35, bottom: 0, right: 0)
    button.contentHorizontalAlignment = .left
    
    button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    return button
  }
  
  @objc private func buttonPressed(_ sender: UIButton) {
    let buttonTitle = sender.titleLabel?.text ?? ""
    let message = "\(buttonTitle) button has been pressed"
    
    let alert = UIAlertController(
      title: "Button Pressed",
      message: message,
      preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default)
    alert.addAction(action)
    
    present(alert, animated: true, completion: nil)
  }
  
  func setupButtons() {
    let buttonTitles = [
      "Share Profile", "Favorites Messages", "Saved Messages",
      "Bookmarks", "History", "Notifications", "Find Friends",
      "Security", "Help", "Logout"]
    //Button의 수가 많기 때문에, 모두 추가하면 스택 뷰 크기가 화면에서 사용한 공간보다 커지기 때문에 모두 표시 되지 않는다.
    //또한 디바이스를 회전시킬 때에도, 제대로 표시되지 않는다.
    //이 경우에는 스크롤 뷰를 사용해야 한다.
    
    let buttonStack = UIStackView()
    buttonStack.translatesAutoresizingMaskIntoConstraints = false
    buttonStack.alignment = .fill
    buttonStack.axis = .vertical
    buttonStack.distribution = .equalSpacing
    
    buttonTitles.forEach { (buttonTitle) in
      buttonStack.addArrangedSubview(createButton(text: buttonTitle))
    }
    
    mainStackView.addArrangedSubview(buttonStack)
    NSLayoutConstraint.activate([
      buttonStack.widthAnchor.constraint(equalTo: mainStackView.widthAnchor),
      buttonStack.centerXAnchor.constraint(equalTo: mainStackView.centerXAnchor)
    ])
  }
}











