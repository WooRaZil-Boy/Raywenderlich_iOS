//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 2. 27..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    //UITableViewController는 화면이 UITableView로 구성된다면 좋은 선택이지만, 여기서는 다른 뷰(UISearchBar 등)도 함께 추가해야 하기 때문에 UIViewController를 사용하는 것이 더 낫다.
    @IBOutlet weak var searchBar: UISearchBar! //Search Bar의 높이는 44로 고정되어 있다(Status bar가 20인 것 처럼).
    @IBOutlet weak var tableView: UITableView!
    //weak var로 선언되었어도, 해당 뷰 컨트롤러의 메인뷰(self.view)가 유지되는 한 항상 이 객체들의 참조를 유지한다.
    //IBOutlet 객체들은 weak으로 선언되었어도, self.view의 서브 클래스로 strong하게 연결되어 있기 때문. //p.784
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let search = Search() //통신의 모든 로직 캡슐화
    var landscapeVC: LandscapeViewController? //세로일 때는 nil, 가로일 때만 값을 가진다.
    
    struct TableViewCellIdentifiers { //재사용 식별자 같은 문자열 리터럴은 상수로 만들어 두는 것이 좋다. //변경이 단일 지점, 한 번으로 제한된다.
        //클래스 안에 구조체를 배치해 해당 클래스의 고유한 구조체를 선언할 수 있다.
        static let searchResultCell = "SearchResultCell" //static으로 선언하면, 인스턴스 없이 사용할 수 있다.
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.rowHeight = 80 //스토리 보드에서 설정해 줄 수도 있다.
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0) //상태표시줄 20, 검색 바 44 세그먼트 컨트롤러 44
        //Content Insight은 Interface Builder에서 지정해 줄 수 없다.
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil) //nib 불러오기
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell) //재사용 식별자 이용해서 tableView에 등록
        //등록 이후, dequeueReusableCell(withIdentifier :)에서 식별자를 이용해 사용할 수 있다.
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil) //nib
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        //nothingFoundCell은 따로 설정할 속성이 없으므로 UITableViewCell의 하위 클래스를 만들 필요가 없다.
        //nib를 등록하는 것으로 충분하다.
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil) //nib
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        //loadingCell은 따로 설정할 속성이 없으므로 UITableViewCell의 하위 클래스를 만들 필요가 없다.
        //nib를 등록하는 것으로 충분하다.
        
        searchBar.becomeFirstResponder() //서치바에 포커스를 줘서, 키보드를 활성화 시킨다.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - PrivateMethods
extension SearchViewController {
    func performSearch() { //키보드의 검색 버튼 눌렀거나, segment controller를 눌러 검색한 경우
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            //segmentedControl의 현재 선택된 인덱스로 category 생성
            //enum이 0 ~ 3이므로 selectedSegmentIndex가 범위를 벗어나는 경우 생성에 실패할 수 있다.
            search.performSearch(for: searchBar.text!, category: category, completion: { success in
                //인터페이스를 업데이트하는 코드는 제거되었다. 이 객체의 메서드는 검색을 수행하는 것. UI업데이트는 Search객체가 아닌 뷰 컨트롤러의 역할이다.
                //따라서 클로저를 받아서 이곳에서 UI업데이트하는 것이 좋은 디자인 이다.
                //delegate 패턴을 만들어도 된다. 하지만, 클로저가 더 간단한 구현.
                if !success { //검색에 문제가 있었다면
                    self.showNetworkError()
                }
                
                self.landscapeVC?.searchResultsReceived() //검색 중 가로로 회전한 경우
                //가로로 회전하지 않은 경우에는 landscapeVC이 nil이 되므로 실행되지 않는다.
                //unwrapping해서 사용해도 되지만, 짧은 경우 optional chaining이 더 효율적이다.
                self.tableView.reloadData() //UI 업데이트 //이 클로저는 메인 스레드에서 호출되므로 UI업데이트를 할 수 있다.
            }) //검색에 대한 모든 로직을 Search 객체에서 담당한다.
            tableView.reloadData() //로딩 중 셀과 스피너 표시
            //여기서 네트워크를 비동기화 하지 않고 메인 스레드에서 실행할 경우,
            //메인 스레드는 네트워킹 작업을 시작하면서, 이벤트를 처리할 수 없어 테이블 뷰가 로딩 중 셀과 스피너가 표시되지 않는다.
            searchBar.resignFirstResponder() //키보드 해제
            //스토리보드에서 tableView - ScrollView에서 keyboard 설정을 바꿔줄 수 있다.
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment:"Network error alert title"), message: NSLocalizedString("There was an error accessing the iTunes Store. Please try again.", comment:"Network error alert message"), preferredStyle: .alert)
        //\n로 연결할 수도 있지만, +로 연결하는 것이 더 직관적
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

//MARK: - Rotaion
extension SearchViewController {
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        //가로 사이즈, 세로 사이즈, 디스플레이 비율(Retina), 인터페이스(iPhone, iPad), Dynamic type font 변경 등의 경우에 호출된다.
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass { //트랜지션 변경 후 세로 사이즈 //회전 감지를 위해선 세로를 확인해야 한다.
        case .compact: //가로
            showLandscape(with: coordinator)
        case .regular, .unspecified: //세로
            hideLandscape(with: coordinator)
        }
        //Horizontal x Vertical
        //compact x compact : iPhone Landscape
        //compact x regular : iPhone Portrait
        //regular x compact : iPhone Plus Landscape
        //regular x regular : iPad Portrait, iPad Landscape
        //p.956
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        //LandscapeViewController를 SearchViewController의 하위 뷰 컨트롤러로 추가한다.
        //Modal에서나 다른 뷰 컨트롤러 전환과 달리 segue를 만들지 않는다.
        guard landscapeVC == nil else { //LandscapeViewController가 존재하면 return
            return
        }
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController //Storyboard ID로 인스턴스화
        if let controller = landscapeVC { //unwrapping
            controller.search = search //검색를 담당하는 객체를 전달
            controller.view.frame = view.bounds //뷰 컨트롤러 크기 전체화면 덮게.
            controller.view.alpha = 0
            
            view.addSubview(controller.view) //SearchViewController의 뷰가 부모 뷰가 된다. (현재 뷰 컨트롤러의 가장 위로 배치된다.)
            //controller.view가 SearchViewController의 테이블 뷰, 서치 바, 세그먼트 컨트롤 위에 배치
            addChildViewController(controller) //하위 뷰 컨트롤러로 추가 //화면의 해당 부분을 담당하고 있음을 알린다.
            //willMove가 addChildViewControlle()에 의해 자동적으로 호출된다.(제거할 때는 반대로)
            
            coordinator.animate(alongsideTransition: { _ in //애니메이션 추가
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder() //키보드 해제
            }, completion: { _ in
                controller.didMove(toParentViewController: self) //뷰 컨트롤러 계층 구조로 들어갔음을 알림
                //뷰 컨트롤러가 컨테이너 뷰 컨트롤러에 추가되거나 제거된 후 호출된다.
                //addChildViewController에서 이미 추가. //따라서 이 코드가 꼭 필요하지 않는 경우도 있다.
                //하지만 UIKit은 정확히 이 메서드를 호출해야 하는 시점을 알지 못하기 때문에 추가해 주는 것이 좋다.
                //제거할 때는 반대로 didMove()가 자동으로 호출되고, willMove()를 명시적으로 호출한다.
                
                if self.presentedViewController != nil { //Modal 뷰 컨트롤러가 있는 경우
                    //현재 뷰 컨트롤러가 다른 뷰 컨트롤러를 Modal로 표시하지 않으면 nil이다.
                    self.dismiss(animated: true) //닫기
                }
            })
            
            //SearchViewController가 부모가 되고, LandscapeViewController이 자식이 된다.
            //Landscaped의 스크린은 SearchViewController 안에 내장된다.
            //이런 식으로 전환하면, 자식 뷰 컨트롤러는 부모 뷰 컨트롤러에 포함되어 있으므로 부모 뷰 컨트롤러에서 소유하고 관리한다.
            //Modal처럼 독립적이지 않으며, Modal처럼 표현되지도 않는다.
            //따라서 자식 뷰 컨트롤러는 부모 UINavigationController, UITabBarController의 하위 컨트롤러가 된다.
            //일반적으로 전체 화면 영역을 차지하는 뷰 컨트롤러를 표시할 때는 Modal을 사용해야 하고,
            //화면 일부를 관리하려면 ChildViewController로 관리한다.
            //여기서는 전체화면을 차지해서 Modal로 구현하는 것이 적절하지만,
            //세부 항목 뷰 컨트롤러가 이미 Modal로 구현되어 있어, 가로모드도 Modal로 하면 충돌이 일어날 수도 있다.
        }
        
        //a. 자식 뷰 컨트롤러의 뷰를 부모 뷰 컨트롤러의 뷰에 추가한다.
        //b. 부모 뷰 컨트롤러에서 자식 뷰 컨트롤러를 추가한다.
        //c. 전환
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParentViewController: nil) //뷰 컨트롤러 계층 구조에서 벗어난다는 것을 알림
            //뷰 컨트롤러가 컨테이너 뷰 컨트롤러에 추가되거나 제거되기 전에 호출된다.
            //메모리 해제할 것이기에 부모 뷰가 존재할 필요 없으므로 toParentViewController는 nil이 된다.
            
            coordinator.animate(alongsideTransition: { _ in //애니메이션 추가
                controller.view.alpha = 0
                
                if self.presentedViewController != nil { //detailViewController가 떠져 있는 상황에서 가로 -> 세로로 올 경우
                    self.dismiss(animated: true, completion: nil) //detailViewController를 닫는다.
                }
            }, completion: { _ in
                controller.view.removeFromSuperview() //뷰 제거
                controller.removeFromParentViewController() //뷰 컨트롤러 제거
                //삭제 이후에는 didMove()가 자동으로 호출된다.
                //추가할 때는 반대로 didMove()를 명시적으로 호출하고, willMove()가 자동으로 호출된다.
                self.landscapeVC = nil //메모리 해제
            })
        }
    }
    
    //하나의 화면에는 하나의 뷰 컨트롤러가 있는 것이 원칙. 그러나 화면이 커지면서 한 화면에 뷰 컨트롤러를 나눠 각각 제어하게 만들 수 있다.
    //뷰 컨트롤러가 다른 뷰 컨트롤러의 일부가 되는 것을 view controller containment라 한다. iPad에 주로 쓰이지만, iPhone도 사용 가능하다.
    //LandscapeViewController에 뷰 컨트롤러를 포함시킨다. Modal을 만들고 애니메이션으로 구현해도 되지만 다른 방법으로 구현.
    //뷰 컨트롤러를 포함시키는 방법에는 3가지가 있다.
    //1. LandscapeViewController로 만들지 않고, View로 만들어 SearchViewController의 하위뷰로 추가한다.
    //   하지만 이 방법은 SearchViewController에 LandscapeView의 로직이 섞이므로 좋은 방법이 아니다.
    //   각 화면의 로직은 자체 뷰 컨트롤러에 있어야 한다.
    //2. View Controller containment API를 사용해 LandscapeViewController를 SearchViewController 내부에 임베드 한다. (여기선 이 방법을 쓴다.)
    //3. presentation controller를 사용해 Modal segue가 ViewController를 화면에 표시하는 방법을 정의해 줄 수 있다.
    //   DimmingPresentationController에서 해결하는 방법이 3번이다.
}

//MARK: - Actions
extension SearchViewController {
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
        //검색 전에 segment controller를 사용하면 검색할 카테고리 결정
        //검색 이후 segment controller를 사용하면 해당 카테고리만 다시 검색
    }
}

//MARK: - Navigations
extension SearchViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state { //.results의 경우에만 신경 쓰면 된다.
                //하나의 경우에만 신경스면 되므로 Switch를 쓸 필요 없이 case if 문으로 단일 사례를 처리할 수 있다.
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row] //터치한 셀의 정보
                detailViewController.searchResult = searchResult
            }
        }
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition { //바의 위치를 지정한다.
        //UISearchBarDelegate가 확장한 UIBarPositioningDelegate에 위치
        //UINavigationBar, UISearchBar는 default가 .top
        //UIToolbar는 default가 .bottom
        
        return .topAttached //바가 위에 위치하면서 배경을 Status bar까지 확장한다.
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource { //UITableViewController가 아닌 UITableView를 UIViewController에 추가한 것이므로 UITableViewDataSource를 직접 연결해 줘야 한다.
    //UITableViewController와 달리 메서드를 재정의하는 것이 아니므로 override도 아니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet: //앱 처음 시작 시
            return 0
        case .loading: //로딩 중일 때
            return 1
        case .noResults: //검색 결과가 없을 때
            return 1 //검색 결과가 없다는 걸 알리기 위해 하나의 셀이 필요하다.
        case .results(let list): //검색 결과가 있을 때
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet: //cell이 0개 이므로 여기로 와선 안 된다.
            fatalError("Should never get here")
        case .loading: //로딩 중 일때
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView //로딩 셀에서 spinner 찾기
            spinner.startAnimating()
            
            return cell
        case .noResults: //검색 결과가 없을 때
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell //재사용 셀
            //dequeueReusableCell(withIdentifier: for:)메서드는 nib나 스토리보드에서 프로토 타입 셀을 사용한 경우에만 사용할 수 있다.
            //static cell을 사용할 경우는 따로 indexPath를 받아 수정할 필요없이 스토리보드에서 디자인을 처리할 수 있다.
            
            let searchResult = list[indexPath.row]
            cell.configure(for: searchResult)
            
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate { //UITableViewController가 아닌 UITableView를 UIViewController에 추가한 것이므로 UITableViewDelegate를 직접 연결해 줘야 한다.
    //UITableViewController와 달리 메서드를 재정의하는 것이 아니므로 override도 아니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //셀 선택 시
        tableView.deselectRow(at: indexPath, animated: true) //선택 해제
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        //프로토 타입 셀을 사용하지 않기 때문에 ViewController 자체에 segue를 설정해야 한다.
        //수동으로 segue를 트리거 하도록 만들어야 한다.
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { //셀이 선택 되기 전
        switch search.state {
        case .notSearchedYet, .loading, .noResults: //검색 결과가 없거나(혹은 앱이 처음 시작했을 때) 로딩 중이면, 셀 선택을 할 수 없게
            //cell의 selection Style의 속성을 변경하지 않으면, 연속해서 탭하는 경우 잠시 회색으로 빠르게 변경될 수 있다.
            //nil을 반환하게 하더라도, UIKit은 셀을 오랫동안 누르고 있으면 선택된 배경을 그린다.
            return nil
        case .results: //검색 결과가 있을 경우에만 셀을 선택할 수 있다.
            //.results의 경우라도, 결과 배열을 사용하지 않으므로 바인딩할 필요 없다.
            return indexPath
        }
    }
}

//버전 관리
//M : 커밋 이후 파일이 수정 됨, A : 이름이 바뀐 파일

//Crash 된 경우, Console 창에서 (lldb) 이후에 디버거를 입력할 수 있다. p.820
//Break Point는 해당 코드 줄이 실행되기 직전에 호출된다.
//Breakpoint navigator - + button - Exception Breakpoint로 crash가 발생할 때마다 트리거 되는 Break Point를 추가할 수 있다.
//EXC_BAD_INSTRUCTION, SIGABRT등의 메시지를 출력하며 충돌하는 경우, 디버거에서 메시지를 찾고, lldb를 활용
//AppDelegate에서 충돌이 발생했다고 나타나는 경우, Break Points를 활용해 찾아낸다.
//SIGABRT 메시지를 내며 충돌하지만, 다른 오류 메시지가 없을 경우, Exception Breakpoints를 비활성화 하고 다시 Crash하면서 오류 메시지를 찾아 낼 수 있다.
//EXC_BAD_ACCESS는 대개 메모리 관리에 문제 있을 때 나타난다.
//EXC_BREAKPOINT는 오류가 아니다. Break point로 중단한 것.
//Report navigator에서 Build 시 log를 확인할 수 있다.

//하나의 객체가 여러개의 @IBOutlet에 연결될 수도 있다.

//Bool을 flag로 사용하는 경우가 종종 있다. 옵셔널로도 처리할 수 있지만 옵셔널은 될 수 있으면 피하는 것이 좋다.

//Open Developer Tool → More Developer Tools... 에서 개발자 도구를 추가로 다운로드할 수 있다.
//네트워크 속도를 테스팅할 수 있는 Network Link Conditioner 추가 p.862
//네트워크가 지연되는 경우를 Network Link Conditioner없이 사용하고 싶은 경우는 sleep() 함수를 쓸 수 있다. p.1008

//Source Control navigator에서 Branch를 손쉽게 생성할 수 있다.
//브런치를 변경해 소스를 업데이트하거나 버그를 수정하고 다시 마스터 브런치와 병합할 수 있다.
//아직 버그가 있는 경우가 종종 있다. 그럴 땐 터미널에서 하는 것이 낫다.

//URLSession을 대체할 수 있는 네트워킹 라이브러리
//AFNetworking(github.com/AFNetworking)
//Alamofire(github.com/Alamofire)

//internationalization를 "i18n"라 하기도 한다.
//지역화를 위해 인터페이스 빌더 - File inspector - Localize... 버튼을 눌러 추가하면 된다.
//Project에서 사용 언어를 추가 (순서 바껴도 상관 없음)
//지역화를 나중에 추가하게 되면, 앱을 제거하고 새로 빌드해야 할 수도 있다. nib이 현지화 되지 않았기 때문이다.
//따라서 인터페이스 빌더를 만들 때 en.lproj나 Base.lproj에 모든 nib 파일과 스토리 보드를 넣는 게 좋다. (Base를 만들어 놓는 것이 좋다.)
//Base.lproj를 사용하면, 전체 nib를 복사하지 않고 문자열만을 복사해 번역할 수 있다.
//Finder에서 해당 nib가 Base.lproj 폴더로 이동했는지 확인해보면 된다.
//Assistant editor - Preview에서 미리보기할 수 있다.



