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

class CatFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  private let kCatCellIdentifier = "CatCell"
  private let screensFromBottomToLoadMoreCats: CGFloat = 2.5
  
  private var photoFeed: PhotoFeedModel?
  private let tableView = UITableView(frame: CGRect.zero, style: .plain)
  private let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    navigationItem.title = "Catstagram".localized(comment: "Application title")

    tableView.autoresizingMask = UIViewAutoresizing.flexibleWidth;
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    photoFeed = PhotoFeedModel(imageSize: imageSizeForScreenWidth())
    view.backgroundColor = .white
    
    refreshFeed()
    
    view.addSubview(tableView)
    tableView.allowsSelection = false
    tableView.separatorStyle = .none
    tableView.register(CatPhotoTableViewCell.classForCoder(), forCellReuseIdentifier: kCatCellIdentifier)
    
    tableView.addSubview(activityIndicatorView)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
    activityIndicatorView.center = CGPoint(x: view.bounds.size.width/2.0, y: view.bounds.size.height/2.0)
  }

  @IBAction func exitAddModal(segue: UIStoryboardSegue) {
    // Exit segue doesn't do anything other than dismiss the view
  }

  func refreshFeed() {
    guard let photoFeed = photoFeed else { return }
    
    activityIndicatorView.startAnimating()
    photoFeed.refreshFeed(with: 4) { (photoModels) in
      self.activityIndicatorView.stopAnimating()
      self.insert(newRows: photoModels)
      self.requestComments(forPhotos: photoModels)
      self.loadPage()
    }
  }
  
  func loadPage() {
    guard let photoFeed = photoFeed else { return }
    
    photoFeed.requestPage(with: 20) { (photoModels) in
      self.insert(newRows: photoModels)
      self.requestComments(forPhotos: photoModels)
    }
  }
  
  func insert(newRows photoModels: [PhotoModel]) {
    guard let photoFeed = photoFeed else { return }
    
    var indexPaths = [IndexPath]()
    
    let newTotal = photoFeed.numberOfItemsInFeed()
    for i in (newTotal - photoModels.count)..<newTotal {
      indexPaths.append(IndexPath(row: i, section: 0))
    }
    tableView.insertRows(at: indexPaths, with: .none)
  }
  
  func requestComments(forPhotos photoModels: [PhotoModel]) {
    guard let photoFeed = photoFeed else { return }
    
    for photoModel in photoModels {
      photoModel.commentFeed.refreshFeed(with: { (commentModels) in
        let rowNum = photoFeed.index(of: photoModel)
        let indexPath = IndexPath(row: rowNum, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? CatPhotoTableViewCell {
          cell.loadComments(forPhoto: photoModel)

          if let firstCell = tableView.visibleCells.first,
            let visibleCellPath = tableView.indexPath(for: firstCell) {
            if indexPath.row < visibleCellPath.row {
              let width = view.bounds.size.width
              let commentViewHeight = CommentView.height(forCommentFeed: photoModel.commentFeed, withWidth:width)
              
              tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y + commentViewHeight)
            }
          }
        }
      })
    }
  }
  
  //MARK: Table View Delegate
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: kCatCellIdentifier, for: indexPath) as! CatPhotoTableViewCell
    
    cell.updateCell(with: photoFeed?.object(at: indexPath.row))
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let photoModel = photoFeed?.object(at: indexPath.row) {
      return CatPhotoTableViewCell.height(forPhoto: photoModel, with: view.bounds.size.width)
    }
    return 0
  }
  
  //MARK: Table View DataSource
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return photoFeed?.numberOfItemsInFeed() ?? 0
  }
  
  //MARK: Scroll View Delegate
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let screensFromBottom = (scrollView.contentSize.height - scrollView.contentOffset.y)/UIScreen.main.bounds.size.height;
    
    if screensFromBottom < screensFromBottomToLoadMoreCats {
      loadPage()
    }
  }
  
  //MARK: Helpers
  func imageSizeForScreenWidth() -> CGSize {
    let screenRect = UIScreen.main.bounds
    let scale = UIScreen.main.scale
    
    return CGSize(width: screenRect.width * scale, height: screenRect.width * scale)
  }
  
  func resetAllData() {
    photoFeed?.clearFeed()
    tableView.reloadData()
    refreshFeed()
  }
}

//2. Breakpoint Improvements
//breakpoint에는 4가지 종류가 있다.
//exception breakpoint, sharing breakpoint, logging breakpoint, symbolic breakpoint
//crash로 종료된 경우, 콘솔을 확인해 보면 단서를 찾을 수 있다(uncaught exception 등).
//breakpoint navigator 좌측 하단의 + 버튼으로 여러 가지 종류의 breakpoint를 추가할 수 있다.
//Exception breakpoint는 Objective C로 되어 있다(UIKit이 Objective C).
//Exception breakpoint를 설정하면(default), crash 대신 breakpoint에서 앱이 멈춘다.
//Stack을 살펴보면, 첫 번째로 objc_exception_throw가 있다.
//Exception breakpoint는 에러가 발생한 위치에서 멈춘다.
//그 후, (lldb) po 등을 사용해서 값을 확인해 볼 수 있다.
//exception breakpoint는 개발자가 일일이 breakpoint를 직접 설정하지 않아도 되서 편리하다.
//해당 exception breakpoint를 navigator에서 우클릭 - Move breakpoint to - User 로 설정하면
//User header 밑에 breakpoint가 들어간다. 이 상태에서 어떤 프로젝트를 실행해도 같은 breakpoint가 설정된다.
//해당 프로젝트를 같이 개발하는 다른 개발자에게 breakpoint를 공유해 줄 수 있는데, 이를 share breakpoint라 한다.
//breakpoint(일반 breakpoint도 가능)를 설정하고 navigator에서 우클릭 - Share Breakpoint를 설정하면 된다.
//그러면 breakpoint가 저장되고, git 등을 통해 파일 관리할 때 공유된다.




//3. Logging Using Breakpoints
//num line이나 navigator에서 설정한 Breakpoint를 우클릭해서 Edit Breakpoint를 눌러 수정할 수 있다.
//Add action 버튼을 클릭하면, Debugger Command를 선택해 출력을 설정해 줄 수 있다. ex. po screensFromBottom
//이후 밑의, Options에서 Automatically contnue를 체크해 반복되는 경우 breakpoint를 멈추지 않고 진행할 수 있다.
//예를 들어 위의 table에서 반복해서 breakpoint가 걸리는 경우, 멈추지 않고 po만 콘솔에 출력하고 continue 된다.
//Add action 버튼 중 Log Message를 선택해 출력할 수도 있다.
//ex. screensFromBottom: @screensFromBottom@ Threshhold: @screensFromBottomToLoadMoreCats@
//message를 적을 때, hint를 보면 @@ 사이에 표현을 써줘야 한다.
//일반 print("screensFromBottom: \(screensFromBottom) Threshhold: \(screensFromBottomToLoadMoreCats)") 와 같은 표현으로 볼 수 있다.
//이렇게 설정해, 각 tableView cell의 이미지가 보여질 때마다 각 cell의 크기 등을 확인해 디버깅할 수 있다.
//우측 하단 콘솔 창에서 All Output 대신 Debugger Output을 선택하면 해당 출력만 필터링할 수 있다.




//4. Breaking in UIKit
//Debug navigator에서 CPU 점유율, Memory 사용량 등을 그래프로 확인해 볼 수 있다.
//뷰 컨트롤러를 present 한 이후 메모리 사용량이 증가 한 후, dismiss한 이후에 떨어지지 않거나 (반복하면 계속 증가)
//tableView 등을 스크롤 했을 때 계속해서 메모리 사용량이 증가한다면, 문제가 있는 것을 알 수 있다.
//뷰 컨트롤러가 해제되지 않아 메모리가 누수되면, dealloc 메서드가 제대로 작동하지 않는 것이다.
//Breakpoint에서 이를 확인할 수 있다. Breakpoint navigator에서 좌측 하단의 + 버튼을 선택한다.
//Symbolic Breakpoint를 추가해 Symbol에 -[UIViewController dealloc]
//UIKit이 Objective-C로 만들어 졌기 때문에 Swift를 쓰더라도, 해당 symbol에서 Onjective-C로 써줘야 한다.
//실제로 Swift 앱에서 deinit 될 때 UIKit은 Objective-C의 dealloc를 호출한다.
//해당 Breakpoint를 추가하면, UIViewController가 해제될 때 디버거가 앱이 멈추면서 어셈블리 코드를 보여준다.
//해당 코드의 가장 위에 [UIViewController dealloc]이 호출된 것을 알 수 있다.
//어느 UIViewController가 dealloc을 호출했는지는 해당 메서드의 첫 번째 매개변수로 알 수 있다.
//(lldb) 콘솔 창에서 (lldb) po $arg1 를 입력해 해당 ViewController를 출력해 볼 수 있다.
//하지만 많은 경우 UINavigationController가 출력 되는 데, 이럴 때에는 breakpoint condition을 추가해 준다.
//breakpoint condition은 filter같은 역할을 한다. condition이 true인 경우에만 breakpoint가 stop된다.
//(lldb) po (BOOL)[$arg1 isKindOfClass:[UIViewController class]] 로
//해당 매개변수가 UIViewController인지 알 수 있다(UINavigationController도 UIViewController 이므로 true).
//(lldb) po (BOOL)[$arg1 isKindOfClass:[CatDetailViewController class]] 로 해당 클래스를 바꿔준다.
//이런 경우 error가 나는데, CatDetailViewController는 Swift 타입이기 때문이다.
//(lldb) po (BOOL)[$arg1 isKindOfClass:(id)NSClassFromString(@"Catstagram.CatDetailViewController"))]
//Swift 클래스를 사용하기 위해서는 위와 같이 사용해야 한다(NSClass를 String으로 인스턴스화 : Module.class).
//Objective-C 에서 String을 사용할 때는 @를 붙여줘야 한다.
//이 condition을 breakpoint condition으로 추가할 수 있다. 위에서 만든 dealloc Symbolic Breakpoint에
//(BOOL)[$arg1 isKindOfClass:(id)NSClassFromString(@"Catstagram.CatDetailViewController"))] 을
//Condition 탭에 추가해 준다(우클릭 - Edit Breakpoint). 해당 조건이 만족한 경우에만 stop된다.
//따라서 해당 ViewController를 dismiss 했는 데도 breakpoint에 걸리지 않는다면 문제가 있는 것으로 알 수 있다.




//5. Challenge: Logging
//Symbolic Breakpoint와 Debugger Command를 결합하여, 사용할 수도 있다.
//reuseable Cell 등을 디버깅할 때 사용할 수 있다.




//8. Inspecting Variables

