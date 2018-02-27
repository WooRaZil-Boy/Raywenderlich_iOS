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
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0) //상태표시줄 20, 검색 바 44
        //Content Insight은 Interface Builder에서 지정해 줄 수 없다.
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
        let cellIdentifier = "SearchResultCell"
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) //재사용 셀
        if cell == nil { //재사용 셀 없으면 생성
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if searchResults.count == 0 { //검색 결과가 없을 때
            cell.textLabel!.text = "(Nothing found)"
            cell.detailTextLabel!.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.textLabel!.text = searchResult.name
            cell.detailTextLabel!.text = searchResult.artistName
        }

        return cell
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
            //cell의 selectionStyle의 속성을 변경하지 않으면, 연속해서 탭하는 경우 잠시 회색으로 빠르게 변경될 수 있다.
            return nil
        } else { //검색 결과가 있을 경우에만 셀을 선택할 수 있다.
            return indexPath
        }
    }
}

//버전 관리
//M : 커밋 이후 파일이 수정 됨, A : 이름이 바뀐 파일
