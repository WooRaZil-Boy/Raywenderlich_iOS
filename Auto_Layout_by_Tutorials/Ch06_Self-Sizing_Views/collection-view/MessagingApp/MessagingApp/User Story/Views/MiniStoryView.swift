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

protocol MiniStoryViewDelegate: class {
  func didSelectUserStory(atIndex index: Int)
}

final class MiniStoryView: UIView {
  // MARK: - Properties
  private let userStories: [UserStory]
  private let cellIdentifier = "cellIdentifier"
  weak var delegate: MiniStoryViewDelegate?
  
  private let verticalInset: CGFloat = 8 //상단, 하단 콘텐츠 인셋
  private let horizontalInset: CGFloat = 16 //좌우 수평 인셋
  private lazy var flowLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 16
    flowLayout.scrollDirection = .horizontal //수평 스크롤
    flowLayout.sectionInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset) //섹션을 설정한다.
    return flowLayout
  }()
  
  private lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.register(MiniStoryCollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
    collectionView.showsHorizontalScrollIndicator = false //수평 스크롤 인디케이터 감춘다.
    collectionView.alwaysBounceHorizontal = true //바운스 설정
    collectionView.backgroundColor = .systemGroupedBackground
    collectionView.dataSource = self
    collectionView.delegate = self
    return collectionView
  }()
  
  // MARK: - Initializers
  init(userStories: [UserStory]) {
    self.userStories = userStories
    super.init(frame: .zero)
    setupCollectionView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    self.userStories = []
    super.init(coder: aDecoder)
  }
  
  // MARK: - Layouts
  private func setupCollectionView() {
    addSubview(collectionView)
    collectionView.fillSuperview()
  }
  
  override func layoutSubviews() {
    //Manually sizing collection view cells
    //cell의 크기를 수동 혹은 자동으로 조정할 수 있다. 여기서는 수동으로 조정한다.
    //flowLayout과 itemSize를 사용하여 cell 크기를 정의할 수 있다.
    super.layoutSubviews()
    
    let height = collectionView.frame.height - verticalInset * 2
    //cell 높이는 collectionView frame의 높이에서 상단 및 하단 inset을 뺀 값이다.
    let width = height //cell의 너비는 높이와 같다.
    let itemSize = CGSize(width: width, height: height)
    flowLayout.itemSize = itemSize
    //CollectionView가 배치된 이후, 프레임 높이를 변경하는 경우 여기서 flowLayout의 item size를 변경하면 된다.
  }
}

// MARK: - UICollectionViewDataSource
extension MiniStoryView: UICollectionViewDataSource {
  // 1
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return userStories.count
  }
  
  // 2
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView .dequeueReusableCell(
      withReuseIdentifier: cellIdentifier,
      for: indexPath) as? MiniStoryCollectionViewCell
      else { fatalError("Dequeued Unregistered Cell") }
    let username = userStories[indexPath.item].username
    cell.configureCell(imageName: username.rawValue)
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension MiniStoryView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.didSelectUserStory(atIndex: indexPath.item)
  }
}

//Collection View
//Table View는 행의 단일 열을 제공한다. Collection View는 다양한 항목의 요소로 구성할 수 있다.

//Why collection view?
//collection view는 UIKit 프레임워크에서 가장 기능이 풍부한 레이아웃 도구 중 하나이다.
//collection view는 상상할 수 있는 거의 모든 레이아웃의 항목을 표시할 수 있다.
//UICollectionView는 UITableView보다 유연성이 뛰어나다.
//Collection views는 그리드 레이아웃에서 탁월하다.
//App Store, Photos, Instagram, Pinterest, Netflix, Airbnb 등 많은 앱에서 그리드 레이아웃을 구현하고 있다.

//Collection view anatomy
//collection view에는 4가지 기본 구성요소가 있다.
// • UICollectionViewLayout : 모든 Collection View에는 레이아웃 객체가 필요하다.
//  UICollectionViewLayout은 컬렉션 내의 항목이 어떻게 배치되고 보이는지 결정한다.
//  collection view cell, supplementary view, decoration view 등의 항목을 다룬다.
// • UICollectionViewCell : UITableViewCell과 유사하지만, 더 유연하다. 셀의 높이 외에도 너비를 구성할 수 있다.
// • Supplementary View : header와 footer를 표시할 수 있다.
// • Decoration View : collection view cell와 supplementary view 달리, decoration view는 data source와 돌릭접이다.
//  Decoration View는 섹션 또는 전체 컬렉션 뷰에 대한 시각적인 장식으로, 일반적으로 사용하지 않아도 된다.

//UICollectionViewLayout와 UICollectionViewCell는 반드시 필요하고, Supplementary View와 Decoration View는 선택사항이다.
//항목을 그리드로 구성하려면 일반적으로 UIKit, UICollectionViewFlowLayout과 함께 제공되는 concrete layout 객체를 사용한다.
//따라서 세부 정보를 구현할 필요가 없다. UICollectionViewFlowLayout은 항목을 그리드로 구성하기 위한 UICollectionViewLayout의 하위 클래스이다.
//원형 레이아웃 등 다른 레이아웃을 사용하려면, UICollectionViewLayout의 서브 클래스를 구성한다.
//여기서는 UICollectionViewFlowLayout를 사용하며, decoration view를 생략한다.

//Building mini-story view
//Snapchat, Messenger, Instagram 등에서 쉽게 찾아 볼 수 있는 스토리 공유 기능의 레이아웃을 구성해 본다.




