//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2016. 12. 7..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    struct TableViewCellIdentifiers { //struct 안에 static let을 선언하면 전역 변수처럼 사용하기 전에는 인스턴스화 시키지 않는다. (lazy 처럼).
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    //MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let search = Search()
    var landscapeViewController: LandscapeViewController?
    weak var splitViewDetail: DetailViewController?
}

//MARK: - ViewLifeCycle
extension SearchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0) //tableView의 inset을 설정하는 것은 StoryBoard에 없어서 직접 해 주어야 한다. 테이블 뷰의 위치를 직접 내리는 것 보다 이런 식으로 inset을 넣어 주는 편이 더 깔끔하다. //status bar : 20 point, Search bar : 44 point
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
        
        if UIDevice.current.userInterfaceIdiom != .pad { //아이패드가 아닐 때에만 디폴트로 키보드를 올림 //아이팟 터치는 .phone으로
            searchBar.becomeFirstResponder()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) { //회전 뿐 아니라 뷰 컨트롤러 속성이 변할 때 호출되는 메서드 //가로, 세로, 레티나 여부, iPhone, iPad, 글꼴 크기 등
        super.willTransition(to: newCollection, with: coordinator)
        
        let rect = UIScreen.main.bounds
        if (rect.width == 736 && rect.height == 414) /*portrait*/ || (rect.width == 414 && rect.height == 736) /*landscape*/ { //플러스 일 시 //splite에서 떠 있는 창을 지워준다. //x3를 사용하고 있는 스크린을 골라서 확인할 수도 있다. (현재 x3를 사용하는 디바이스가 플러스 뿐) 하지만 이 방법은 줌 등의 옵션 사용하면 다른 디바이스도 x3으로 인식 될 수도 있다. //또 다른 방법으로 API 통해 현재 모델을 알아 낼 수 있지만, 여러 요인들에 의해 다른 모델 이름을 가지는 경우도 종종 있다.
            if presentedViewController != nil {
                dismiss(animated: true, completion: nil)
            }
        } else if UIDevice.current.userInterfaceIdiom != .pad {
            switch newCollection.verticalSizeClass { //*아이폰(+포함) 세로 모드 :: compact, regular, *아이폰 가로 모드(+제외) :: compact, compact, *6(7)+ 가로모드 :: regular, compact, *아이패드 :: regular, regular
            case .compact:
                showLandscape(with: coordinator)
            case .regular, .unspecified:
                hideLandscape(with: coordinator)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Methods - Network
extension SearchViewController {
    func showNetworkError() {
        let alert = UIAlertController(
            title: NSLocalizedString("Whoops...", comment: "Error alert: title"), message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"), preferredStyle: .alert)
        
        let action = UIAlertAction(title: NSLocalizedString("OK", comment: "Error alert: OK"), style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - Navigations
extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" { //아이폰
            if case .results(let list) = search.state { //if case = 로 필요한 부분만 간단히 작성할 수 있다.
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                detailViewController.searchResult = searchResult
                detailViewController.isPopUp = true //아이폰에서는 팝업 뜨게 해 줘야.
            }
        }
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(for: searchBar.text!, category: category, completion: { success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData() //검색 완료 후 리로드
                self.landscapeViewController?.searchResultsReceived() //가로 모드 일 때 검색 결과 전달 //옵셔널 체이닝에 의해 가로모드가 아닐 때에는 무시된다.
            })
            
            tableView.reloadData() //검색 중에 리로드
            searchBar.resignFirstResponder()
        }
    }
    
    
    
    
    
//    func performSearch() {
//        if !searchBar.text!.isEmpty {
//            searchBar.resignFirstResponder()
//            
//            dataTask?.cancel() //이전 검색 중에 다시 검색을 실행하면 이전 검색을 취소한다.
//            isLoading = true
//            
//            tableView.reloadData() //검색 중이라는 셀 띄워주기 위해
//            
//            hasSearched = true
//            searchResults = []
//            
//            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
//            let session = URLSession.shared //캐싱, 쿠키 등 기본 옵션 세션 //와이파이, 셀룰러 제한 등 설정하려면 URLSessionConfiguration 이용해 URLSession 만들어야 한다. //URLSession은 자동으로 캐싱 설정이 되어 있다.
//            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in //dataTask - HTTPS GET 으로 url에 요청
//                if let error = error as? NSError, error.code == -999 { //취소한 경우
//                    return
//                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 { //http 코드 200 == 성공 //response는 URLResponse. http코드를 프로퍼티로 가지고 있지 않다. 서브 클래스인 HTTPURLResponse로 캐스팅해서 확인 //계속해서 옵셔널 해제해야 할 경우, 이렇게 한 줄에서 콤마 써가며 확인하는 것이 편하다.
//                    
//                    //print("On main thread? " +  (Thread.current.isMainThread ? "Yes" : "No")) //메인 스레드인지 확인
//                    
//                    if let data = data, let jsonDictionary = self.parse(json: data) {
//                        self.searchResults = self.parse(dictionary: jsonDictionary)
//                        self.searchResults.sort(by: <)
//                        
//                        DispatchQueue.main.async {
//                            self.isLoading = false
//                            self.tableView.reloadData()
//                        }
//                        
//                        return
//                    }
//                } else {
//                    print("Failure! \(response)")
//                }
//                
//                DispatchQueue.main.async {
//                    self.hasSearched = false
//                    self.isLoading = false
//                    self.tableView.reloadData()
//                    self.showNetworkError()
//                }
//            })
//            
//            dataTask?.resume() //기본적으로 dataTask 자체에 async 설정이 되어 있다?
//        }
//    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet: //cash가 있어 같은 것을 두 번 검색하는 경우에는 응답 받기 전에 먼저 호출 되므로 오류 발생
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath) //꼭 xib 외에 코드 파일을 만들어서 캐스팅해야 되는 것은 아니다. 코드적으로 추가할 것 없으면 그냥 그대로 xib 보여줘도 된다.
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath) //꼭 xib 외에 코드 파일을 만들어서 캐스팅해야 되는 것은 아니다. 코드적으로 추가할 것 없으면 그냥 그대로 xib 보여줘도 된다.
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()

        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact { //아이폰 //iPhone the horizontal size class is always compact (with the exception of the 6 Plus and 6s Plus, more about that shortly). On the iPad it is always regular. //여기 말고 rootView에서 확인하는 이유는 아이패드의 경우 여기에서는 마스터 창 안에 있기 때문에.
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else { //아이패드
            if case .results(let list) = search.state {
                splitViewDetail?.searchResult = list[indexPath.row]
            }
            
            if splitViewController!.displayMode != .allVisible { //.allVisible는 splitViewController의 가로모드 //가로 모드 아닐 때 탭이 되면 행을 숨김
                hideMasterPane()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil //셀이 선택되지 않도록
        case .results:
            return indexPath //나머지 경우에는 선택 되도록
        }
    }
}

//MARK: - Segment
extension SearchViewController {
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
}

//MARK: - Rotations
extension SearchViewController {
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else { //landscapeViewController가 존재하지 않을 때에만
            return
        }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController //landscapeViewController 객체를 스토리보드에서 찾아서 할당
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view) //landscapeViewController의 뷰를 searchViewController의 서브 뷰로. 테이블 뷰나, 서치 뷰 보다도 위인 최상단에 위치하게 된다.
            addChildViewController(controller) //searchViewController의 자식 뷰 컨트롤러로 만든다.
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                
                if self.presentedViewController != nil { //디테일 뷰가 표시된 상태라면 //presentedViewController는 현재 모달 뷰 컨트롤러를 반환한다.
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParentViewController: self) //landscapeViewController에 부모 뷰에서 이동했다는 것을 알려준다.
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil) //부모 뷰 없음.
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
                
                if self.presentedViewController != nil { //디테일 뷰 컨트롤러가 활성화된 상태라면 //모달 뷰를 찾는다.
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil //Strong reference 해제하기 위해
            })
        }
    }
    
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .primaryHidden //splitViewController에서 마스터 분할 창 순김
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        })
    }
}

