//
//  Search.swift
//  StoreSearch
//
//  Created by 근성가이 on 2018. 3. 4..
//  Copyright © 2018년 근성가이. All rights reserved.
//

//import Foundation
import UIKit

typealias SearchComplete = (Bool) -> Void //새로운 타입 설정 //Bool 매개변수를 사용해 Void를 반환하는 클로저 타입
//데이터 유형에 편리한 이름을 추가해 줄 수 있다.

class Search {
    enum Category: Int { //검색 카테고리 범주 //열거형으로 만들어서 더 직관적으로 만들 수 있다.
        //이 열거형을 Search 클래스 밖에 둘 수도 있지만, 서로 밀접한 관련이 있기 때문에 묶어두는 것이 좋다.
        //rawValue가 Int형 //Segument Control의 index와 연동 가능하다.
        case all = 0
        case music = 1
        case software = 2
        case ebooks = 3
        
        var type: String {
            switch self { //Int를 범주에 따라 변환한다.
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebooks: return "ebook"
            }
            //Swift에서는 열거형도 메서드나 computed properties를 가질 수 있다. //인스턴스 변수는 가질 수 없다.
            //객체에 관련된 논리는 그 객체 안에서 해결되도록 디자인하는 것이 좋다.
            
            //이전에 iTunesURL 메서드 안에서 사용될 때에는 category를 매개변수로 받는 대신
            //segmentedControl.selectedSegmentIndex를 직접 사용할 수도 있다.
            //하지만 매개변수를 활용하는 것이 더 나은 디자인인데, Segmented Control을 다른 컨트롤러로 바꾸는 경우에도 해당 메서드를 재사용할 수 있기 때문이다.
            //가능한한 서로 독립되도록 설계하는 것이 좋다.
        }
    }
    
    enum State { //rawValue가 필요없을 경우에는 이런식으로 선언해 줄 수 있다.
        //검색 상태를 나타내는 enum //enum은 제한된 범위의 가능성을 나타내는 데 유용하게 쓸 수 있다.
        case notSearchedYet //오류가 있는 경우에도 사용된다.
        case loading
        case noResults
        case results([SearchResult]) //배열 //다른 모든 경우에는 결과가 없어 배열이 없지만, 결과값이 있는 경우에는 배열에 접근 가능.
        
        //이전 모델에서는 enum을 대신, hasSearched, isLoading, searchResults라는 세 개의 변수로 4가지 상태를 표현했다.
        //세 개의 다른 변수에 흩어져 있어 상태를 직관적으로 알기 어렵다. 따라서 열거형으로 만들어 주는 것이 좋다.
        
        //아직 검색 하지 않음 + 에러 : hasSearched == false, isLoading == false, searchResults.isEmpty == true
        //검색 중 : hasSearched == true, isLoading == true, searchResults.isEmpty == true
        //검색 결과 없음 : hasSearched == true, isLoading == false, searchResults.isEmpty == true
        //검색 결과 : hasSearched == true, isLoading == false, searchResults.isEmpty == false
    }
    
    private(set) var state: State = .notSearchedYet //초기 값으로 notSearchedYet를 가진다.
    //private(set)으로 설정하면, 이 객체 안에서만 해당 변수를 값을 변경 시킬 수 있다. 값을 읽어 오는 것은 다른 객체에서도 가능
    private var dataTask: URLSessionDataTask? = nil //검색 중 취소를 위해 //검색 전에는 데이터 작업이 없으므로 optional
}

//MARK: - HelperMethods
extension Search {
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        //키보드의 검색 버튼 눌렀거나, Segmented controller를 눌러 검색한 경우
        //검색이 완료되면 SearchComplete 클로저를 실행한다.
        //@escaping 키워드는 즉시 사용되지 않는 클로저에 필요하다. 클로저가 변수를 저장하고, 끝날 때까지 그 변수를 유지해야 함을 iOS에 알려준다.
        if !text.isEmpty { //빈 텍스트로 검색한 것이 아니라면
            dataTask?.cancel() //취소. //활성화된 이전 데이터 작업이 있는 경우 취소.
            //처음으로 검색 시에는 dataTask가 nil이므로 해당 코드는 무시 된다.
            UIApplication.shared.isNetworkActivityIndicatorVisible = true //상태 표시창에 스피너 표시
            state = .loading //로딩 중으로 상태 변경

            let url = iTunesURL(searchText: text, category: category)
            //text가 비어 있지 않은 경우에만 조건문에 들어오므로 그대로 사용할 수 있다.
            //iOS 11부터는 Main Thread Checker가 도입되어, 백그라운드에서 UI 코드가 실행중이면 경고를 한다.
            //Edit Scheme... - Run - Diagnostics - Main Thread Checker에 체크
            //이 코드는 UI 컨트롤인 searchBar의 데이터를 사용하므로, queue.async 코드 블럭 안에 위치할 경우 백그라운드 스레드로 엑서스 하므로 경고를 낸다.
            let session = URLSession.shared //URLSession :: 캐싱, 쿠키 등 웹 관련 기본 설정에 사용
            //경우에 따라선 URLSessionConfiguration과 URLSession를 만들어줘야 할 때도 있지만, 이 앱에선 기본 설정으로 충분하다.
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                //세션을 이용해 데이터 작업을 한다. URL의 내용을 오면 클로저 실행
                //클로저는 즉시 실행되지 않고, 객체에 저장되며 나중에 한 번 이상 실행될 수도 있다.
                //data, response, error in 대신 $0, $1, $2로 써도 되지만 가독성을 생각해야 한다.
                //lazy 객체 초기화 등에도 유용하게 사용
                //클로저가 아닌 매개변수가 일치아닌 함수로 대체할 수 있다.
                //클로저는 값을 캡쳐하기 때문에 strong reference가 생길 수 있다. 이런 경우 캡쳐 목록을 제공할 수 있다. (주로 [weak self])
                //이 클로저는 데이터를 불러오는 작업이 금방 종료되므로 strong reference를 걱정할 필요 없다.
                //값이 클로저에 의해 캡쳐되고 있다는 것을 명시적으로 알리기 위해 클로저 내부에서는 속성에 엑서스 하거나 메서드를 호출할 때 self. 를 써야 한다.
                //no escape 클로저의 경우 다른 객체에서 클로저를 호출할 수 없지만, strong reference가 생기지 않는다.
                //자동완성을 더블클릭하면 코드 블럭이 자동으로 추가 된다. //반환형도 생략 가능
                var newState = State.notSearchedYet //에러가 있는 경우에도 notSearchedYet 상태가 된다.
                var success = false //완료 핸들러 위한 bool
                
                if let error = error as NSError?, error.code == -999 { //-999는 cancel된 경우
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data { //없을 경우 //HTTP statusCode 확인
                    //200 : OK, 404 : error //wikipedia.org/wiki/List_of_HTTP_status_codes
                    //response에는 응답 코드와 헤더, data에는 실제 데이터(JSON)이 있다.
                    //Data 객체 타입이므로 내용을 print할 수는 없다.
                    //구문 분석이 쉽기 때문에 XML보다 JSON을 선호한다.
                    //JSON 결과, {}는 딕셔너리, []는 배열
                    //codebeautify.org/jsonviewer
                    var searchResults = self.parse(data: data) //파싱된 결과 가져오기
                    
                    if searchResults.isEmpty { //검색 결과 없는 경우
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <) //각 요소의 name을 비교해 오름차순으로 정렬 //p.858
                        newState = .results(searchResults) //검색 결과 열거형 배열에 추가
                    }
                    
                    success = true
                }
                
                DispatchQueue.main.async {
                    //인터페이스를 업데이트하는 코드는 제거되었다. 이 객체의 메서드는 검색을 수행하는 것. UI업데이트는 Search객체가 아닌 뷰 컨트롤러의 역할이다.
                    self.state = newState //상태를 직접 업데이트 하지 않고, 새 변수인 newState를 사용한 후 여기서 처리.
                    //직접 변경하지 않는 이유는 버그의 원인이 될 수 있기 때문이다.
                    //같은 변수를 동시에 사용하려고 하는 스레드가 여러 개 있을 때, 앱이 충돌할 수 있다.
                    //메인 스레드에서 Search.state에 접근할 수 있는데(로딩 중 표시), 이 때 백그라운드에 있는 URLSession의 클로저와 충돌할 수 있다.
                    //이런 상황을 피하기 위해 메인 스레드에서 작업을 수행
                    completion(success) //성공과 실패 여부를 매개변수로 받는 핸들러 클로저 실행
                    
                    //DispatchQueue.main은 메인 쓰레드와 관련된 큐.
                    //인터페이스 업데이트는 항상 UIKit에 의해 메인 스레드에서 실행되어야 한다. 다른 스레드에서는 UI를 변경할 수 없다.
                    //URLSession은 모든 네트워킹을 백 그라운드 스레드에서 비동기로 실행한다.
                    //즉, 해당 클로저는 메인 스레드에서 실행되지 않기 때문에 UI 업데이트(테이블 뷰 업데이트)를 할 수 없다.
                    //따라서 글로벌 큐에서 진행되는 클로저에서 UI업데이트가 필요한 경우, 메인 쓰레드 큐를 가져와야 한다.
                    //print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
                    //위 코드로 특정 코드가 메인 스레드에서 실행 중인지 알 수 있다.
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    //상태 표시창의 스피너 해제
                }
            })

            dataTask?.resume() //데이터 작업 시작 //URLSession는 기본값으로 비동기 백 그라운드로 진행된다.
            //완료 되면 클로저 실행

            //DispatchQueue.global() //global queue를 참조. medium priority queue //커스텀 큐를 만들 수도 있다.
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

            //queue.async { } //큐에 클로저를 디스패치 //클로저를 백그라운드에 async로 배치
            //해당 클로저를 큐에 예약 하면, 메인 스레드를 차단하지 않는다.
            //HTTP request를 요청할 때는 Synchronous networking을 되도록 피하는 게 좋다.
            //프로그래밍하기는 쉽지만, 인터페이스가 차단되어 네트워킹이 진행되는 동안 앱이 응답하지 않는다(나머지 부분을 차단한다).
            //사용자에게 혼동을 줄 수 있고, 응답 시간이 너무 오래 걸리는 경우에 iOS가 강제 종료할 수도 있다.

            //a가 없는 그냥 queue.sync도 있다. 이렇게 하면 백그라운드에서 코드를 실행하지만, 클로저가 완료될 때까지 기다린다.
        }
    }
}

//MARK: - PrivateMethods
extension Search {
    //앱의 다른 객체에서는 사용하지 않는 메서드들이므로 private로 설정해 줄 수 있다.
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type //열거형 computed property에서 String을 가져온다.
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! //문자열을 urlQueryAllowed로 인코딩한다(이스케이핑).
        //URL에서 공백은 유요한 문자가 아니다. 이 외에도 여러 기호들을 이스케이프 처리해야 한다.(URL 인코딩)
        //UTF-8로 인코딩 한다. UTF-8은 유니코드 텍스트를 인코딩할 때 가장 보편적으로 쓰인다.
        
        let urlString = "https://itunes.apple.com/search?" +
        "term=\(encodedText)&limit=200&entity=\(kind)"
        //HTTPS는 안전하고 암호화 된 HTTP 버전. 기본 프로토콜은 동일하지만 송수신 중인 byte는 네트워킹 전에 암호화된다.
        //iOS 9 이후 부터, HTTPS 사용을 권고. HTTP를 사용해도, iOS는. HTTPS로 연결을 시도하고, HTTPS로 구성되지 않은 네트워크인 경우 연결이 실패한다.
        //info.plist에서 HTTP로 연결되도록 설정할 수 있다.
        let url = URL(string: urlString) //string으로 URL 생성
        
        print("URL :: \(url)")
        
        return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
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
}


//LandscapeViewController에서는 검색 상태(검색 중, 완료)를 알 수 없다.
//SearchViewController의 searchResults를 살펴 보더라도, 검색 결과가 빈 경우가 있으므로 정확하게 알 수 없다.
//간단하게 SearchViewController에서 isLoading 객체를 만들어 LandscapeViewController에 전달할 수도 있다.
//하지만, 검색 로직 자체를 개선하는 것이 더 좋은 디자인 모델이다.
