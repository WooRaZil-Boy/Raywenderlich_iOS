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
    var searchResults = [SearchResult]()
    var hasSearched = false //검색 이후인지 여부.
    //앱이 시작할 때 searchResults가 0이므로 검색결과 없을 때와 같아져서 잘못된 텍스트가 셀에 표시된다.
    //이를 막기 위해 searchResults를 옵셔널로 해서 판단하거나, Bool 변수를 별도로 사용할 수 있다. 옵셔널은 될 수 있으면 피하는 것이 좋다.
    var isLoading = false
    
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
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0) //상태표시줄 20, 검색 바 44
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

//MARK: - Private Methods
extension SearchViewController {
    func iTunesURL(searchText: String) -> URL {
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! //문자열을 urlQueryAllowed로 인코딩한다(이스케이핑).
        //URL에서 공백은 유요한 문자가 아니다. 이 외에도 여러 기호들을 이스케이프 처리해야 한다.(URL 인코딩)
        //UTF-8로 인코딩 한다. UTF-8은 유니코드 텍스트를 인코딩할 때 가장 보편적으로 쓰인다.
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        //C언어에서 주로 쓰이는 formatted string을 이용할 수 있다. %d : 정수, %f : 실수, %@ : 객체
        //HTTPS는 안전하고 암호화 된 HTTP 버전. 기본 프로토콜은 동일하지만 송수신 중인 byte는 네트워킹 전에 암호화된다.
        //iOS 9 이후 부터, HTTPS 사용을 권고. HTTP를 사용해도, iOS는. HTTPS로 연결을 시도하고, HTTPS로 구성되지 않은 네트워크인 경우 연결이 실패한다.
        //info.plist에서 HTTP로 연결되도록 설정할 수 있다.
        let url = URL(string: urlString) //string으로 URL 생성
        
        return url!
    }
    
    func performStoreRequest(with url: URL) -> Data? { //서버 응답과정에서 오류가 있을 수 있으므로 옵셔널
        do {
            return try Data(contentsOf: url) //String을 Data로 변환할 수도 있지만, 서버에서 Data로 받아오는 것이 낫다.
            
//            return try String(contentsOf: url, encoding: .utf8)
            //해당 인코딩(UTF-8)으로 URL의 데이터를 읽어와 String으로 반환한다.
        } catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            
            return nil
        }
    }
    
    func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder() //JSON results 디코더
            let result = try decoder.decode(ResultArray.self, from: data)
            //data를 JSON 디코더를 통해 ResultArray 타입으로 변환한다.
            //프로퍼티 명에 맞춰서 파싱된명.
            
            return result.results //결과에서 배열 부분만 반환
        } catch { //일반적인 통신 오류가 있을 수도 있지만, 서버에서 반환 JSON 형식을 바꿔도 오류가 난다(지정된 형식만 파싱한다).
            //항상 방어적으로 프로그래밍하는 것이 좋다.
            print("JSON Error : \(error)")
            
            return []
        }
    }
    
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...", message: "There was an error accessing the iTunes Store." + " Please try again.", preferredStyle: .alert)
        //\n로 연결할 수도 있지만, +로 연결하는 것이 더 직관적
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //키보드의 검색 버튼 눌렀을 경우
        if !searchBar.text!.isEmpty { //빈 텍스트로 검색한 것이 아니라면
            searchBar.resignFirstResponder() //키보드 해제
            //스토리보드에서 tableView - ScrollView에서 keyboard 설정을 바꿔줄 수 있다.
            isLoading = true
            tableView.reloadData() //로딩 중 셀과 스피너 표시
            //여기서 네트워크를 비동기화 하지 않고 메인 스레드에서 실행할 경우,
            //메인 스레드는 네트워킹 작업을 시작하면서, 이벤트를 처리할 수 없어 테이블 뷰가 로딩 중 셀과 스피너가 표시되지 않는다.
            
            hasSearched = true
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!)
            //searchBar.text가 비어 있지 않은 경우에만 조건문에 들어오므로 force unwrapping할 수 있다.
            //iOS 11부터는 Main Thread Checker가 도입되어, 백그라운드에서 UI 코드가 실행중이면 경고를 한다.
            //Edit Scheme... - Run - Diagnostics - Main Thread Checker에 체크
            //이 코드는 UI 컨트롤인 searchBar의 데이터를 사용하므로, queue.async 코드 블럭 안에 위치할 경우 백그라운드 스레드로 엑서스 하므로 경고를 낸다.
            
            let queue = DispatchQueue.global() //global queue를 참조. medium priority queue //커스텀 큐를 만들 수도 있다.
            //구형 iPhone, iPad에는 CPU(Central Processing Unit)가 하나이지만, 최신 모델에는 2, Mac은 4.
            //코어를 최적화하기 위해 멀티 태스킹과 스레딩을 사용해 한 번에 많은 일을 처리하도록 한다.
            //멀티 태스킹은 여러 앱 간에 발생. 각 앱마다 고유 프로세스가 있다.
            //멀티 스레드는 한 앱 안에서 발생. 각 프로세스는 여러개의 스레드가 있다.
            //메인 스레드는 앱의 초기 스레드이며, 여기에서 다른 모든 스레드가 생성된다.
            //메인 스레드는 인터페이스 이벤트를 처리하고, UI를 그린다. 대부분의 앱 활동은 메인 스레드에서 진행된다.
            //메인 스레드가 이벤트를 처리하고 UI를 그리기 때문에 차단하지 않도록 주의해야 한다.
            //메인 스레드가 다른 작업을 수행하는 동안 UI 이벤트를 처리할 수 없어 앱이 응답하지 않으며, 작업이 너무 오래 걸리면 앱이 시스템에 의해 강제 종료될 수 있다.
            //따라서 오랜 시간이 걸리는 네트워크 통신이나 이미지 로드 등은 스레드를 나눠줘야 한다.
            //Never block the main thread
            
            //새로 스레드를 만드는 대신 iOS는 백 그라운드 프로세스를 제공 : Grand Central Dispatch(GCD)
            //GCD는 병렬 프로그래밍을 단순화시킨다.
            //GCD는 우선 순위가 다른 많은 대기열을 가지고 있다. 하나의 큐에서 하나씩 클로저를 가져오거나 백그라운드에서 코드를 실행한다.
            //Queue는 스레드와 같지는 않지만, 스레드를 사용하여 작업을 수행한다.
            queue.async { //큐에 클로저를 디스패치 //클로저를 백그라운드에 async로 배치
                //해당 클로저를 큐에 예약 하면, 메인 스레드를 차단하지 않는다.
                //HTTP request를 요청할 때는 Synchronous networking을 되도록 피하는 게 좋다.
                //프로그래밍하기는 쉽지만, 인터페이스가 차단되어 네트워킹이 진행되는 동안 앱이 응답하지 않는다(나머지 부분을 차단한다).
                //사용자에게 혼동을 줄 수 있고, 응답 시간이 너무 오래 걸리는 경우에 iOS가 강제 종료할 수도 있다.
                
                //a가 없는 그냥 queue.sync도 있다. 이렇게 하면 백그라운드에서 코드를 실행하지만, 클로저가 완료될 때까지 기다린다.
                if let data = self.performStoreRequest(with: url) {
                    //HTTP request를 서버로 보내 JSON(JavaScript Object Notation) results를 받는다.
                    //구문 분석이 쉽기 때문에 XML보다 JSON을 선호한다.
                    //JSON 결과, {}는 딕셔너리, []는 배열
                    //codebeautify.org/jsonviewer
                    self.searchResults = self.parse(data: data) //파싱된 결과 로컬 변수에 저장
                    self.searchResults.sort(by: <)
                    //자동완성을 더블클릭하면 코드 블럭이 자동으로 추가 된다. //반환형도 생략 가능
                    //각 요소의 name을 비교해 오름차순으로 정렬 //p.858
                    
                    DispatchQueue.main.async { //DispatchQueue.main은 메인 쓰레드와 관련된 큐.
                        //인터페이스 업데이트는 항상 UIKit에 의해 메인 스레드에서 실행되어야 한다. 다른 스레드에서는 UI를 변경할 수 없다.
                        //즉, 해당 클로저는 메인 스레드에서 실행되지 않기 때문에 UI 업데이트(테이블 뷰 업데이트)를 할 수 없다.
                        //따라서 글로벌 큐에서 진행되는 클로저에서 UI업데이트가 필요한 경우, 메인 쓰레드 큐를 가져와야 한다.
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    
                    return
                }
            }
        }
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
        if isLoading { //로딩 중일 때
            return 1
        } else if !hasSearched { //앱 처음 시작 시
            return 0
        } else if searchResults.count == 0 { //검색 결과가 없을 때
            return 1 //검색 결과가 없다는 걸 알리기 위해 하나의 셀이 필요하다.
        } else { //검색 결과가 있을 때
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isLoading { //로딩 중 일때
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView //로딩 셀에서 spinner 찾기
            spinner.startAnimating()
            
            return cell
        }else if searchResults.count == 0 { //검색 결과가 없을 때
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell //재사용 셀
            //dequeueReusableCell(withIdentifier: for:)메서드는 nib나 스토리보드에서 프로토 타입 셀을 사용한 경우에만 사용할 수 있다.
            //static cell을 사용할 경우는 따로 indexPath를 받아 수정할 필요없이 스토리보드에서 디자인을 처리할 수 있다.
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            
            if searchResult.artistName.isEmpty { //아트스트 네임 없는 경우
                cell.artistNameLabel.text = "Unknown"
            } else { //있는 경우엔, 이름과 타입 출력
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, searchResult.type)
            }
            
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate { //UITableViewController가 아닌 UITableView를 UIViewController에 추가한 것이므로 UITableViewDelegate를 직접 연결해 줘야 한다.
    //UITableViewController와 달리 메서드를 재정의하는 것이 아니므로 override도 아니다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { //셀 선택 시
        tableView.deselectRow(at: indexPath, animated: true) //선택 해제
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? { //셀이 선택 되기 전
        if searchResults.count == 0 || isLoading { //검색 결과가 없거나(혹은 앱이 처음 시작했을 때) 로딩 중이면, 셀 선택을 할 수 없게
            //cell의 selection Style의 속성을 변경하지 않으면, 연속해서 탭하는 경우 잠시 회색으로 빠르게 변경될 수 있다.
            //nil을 반환하게 하더라더, UIKit은 셀을 오랫동안 누르고 있으면 선택된 배경을 그린다.
            return nil
        } else { //검색 결과가 있을 경우에만 셀을 선택할 수 있다.
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

//Open Developer Tool → More Developer Tools... 에서 개발자 도구를 추가로 다운로드할 수 있다.
//네트워크 속도를 테스팅할 수 있는 Network Link Conditioner 추가 p.862
