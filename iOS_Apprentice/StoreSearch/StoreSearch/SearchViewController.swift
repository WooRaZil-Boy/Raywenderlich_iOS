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
    
    struct TableViewCellIdentifiers { //재사용 식별자 같은 문자열 리터럴은 상수로 만들어 두는 것이 좋다. //변경이 단일 지점, 한 번으로 제한된다.
        //클래스 안에 구조체를 배치해 해당 클래스의 고유한 구조체를 선언할 수 있다.
        static let searchResultCell = "SearchResultCell" //static으로 선언하면, 인스턴스 없이 사용할 수 있다.
        static let nothingFoundCell = "NothingFoundCell"
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
        //nothingFoundCell셀은 따로 설정할 속성이 없으므로 UITableViewCell의 하위 클래스를 만들 필요가 없다.
        //nib를 등록하는 것으로 충분하다.
        
        searchBar.becomeFirstResponder() //서치바에 포커스를 줘서, 키보드를 활성화 시킨다.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { //키보드의 검색 버튼 눌렀을 경우
        searchBar.resignFirstResponder() //키보드 해제
        //tableView - ScrollView에서 keyboard 설정을 바꿔준다.
        
        searchResults = []
        
        if searchBar.text! != "justin bieber" { //검색결과가 있다면
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake Result %d for", i)
                //C언어에서 주로 쓰이는 formatted string을 이용할 수 있다. %d : 정수, %f : 실수, %@ : 객체
                searchResult.artistName = searchBar.text!
                //작은 따옴표를 넣어 텍스트 전후에 공백 있는지 확인할 수 있다.
                
                searchResults.append(searchResult)
            }
        }
        
        hasSearched = true
        tableView.reloadData() //데이터 다시 불러올 수 있도록 리로드
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
        if !hasSearched { //앱 처음 시작 시
            return 0
        } else if searchResults.count == 0 { //검색 결과가 없을 때
            return 1 //검색 결과가 없다는 걸 알리기 위해 하나의 셀이 필요하다.
        } else { //검색 결과가 있을 때
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchResults.count == 0 { //검색 결과가 없을 때
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell //재사용 셀
            //dequeueReusableCell(withIdentifier: for:)메서드는 nib나 스토리보드에서 프로토 타입 셀을 사용한 경우에만 사용할 수 있다.
            //static cell을 사용할 경우는 따로 indexPath를 받아 수정할 필요없이 스토리보드에서 디자인을 처리할 수 있다.
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel.text = searchResult.artistName
            
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
        if searchResults.count == 0 { //검색 결과가 없으면(혹은 앱이 처음 시작했을 때), 셀 선택을 할 수 없게
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
