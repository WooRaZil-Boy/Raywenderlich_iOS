/*
 * Copyright (c) 2016-present Razeware LLC
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
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

func cachedFileURL(_ fileName: String) -> URL {
    return FileManager.default
        .urls(for: .cachesDirectory, in: .allDomainsMask)
        .first!
        .appendingPathComponent(fileName)
}

class ActivityController: UITableViewController {

  private let repo = "ReactiveX/RxSwift"

  private let events = Variable<[Event]>([])
    //• Variable : BehaviorSubject를 래핑. 현재값을 상태로 유지하고
    //최신/초기 값만 구독자에게 알린다. BehaviorSubject를 더 쉽게 사용한다.
  private let bag = DisposeBag()
    
    private let eventsFileURL = cachedFileURL("events.plist")
    //디스크에 저장해, 사용자가 앱을 열면 마지막으로 가져온 이벤트가 즉시 표시되도록 한다.
    private let modifiedFileURL = cachedFileURL("modified.txt")
    //서버가 JSON 응답과 함께 보내는 Last-Modified라는 헤더 값을 저장한다. //최종 서버 연결 시간을 나타낸다.
    //다음에 서버와 통신 시 동일한 헤더를 서버에 다시 보내면, 서버에서 새로운 이벤트만을 파악할 수 있게 된다. p.173
    //이렇게 이전에 없었던 최신 이벤트만 요청하도록 해서 트래픽을 줄이고 메모리를 최적화할 수 있다.
    private let lastModified = Variable<NSString?>(nil)
    //modified.txt의 값을 저장해 놓을 변수 //NSString은 NSArray처럼 편리하게 디스크에 읽고 쓸 수 있다.

  override func viewDidLoad() {
    super.viewDidLoad()
    title = repo

    self.refreshControl = UIRefreshControl()
    let refreshControl = self.refreshControl!

    refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
    refreshControl.tintColor = UIColor.darkGray
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    
    let eventsArray = (NSArray(contentsOf: eventsFileURL) as? [[String: Any]]) ?? []
    //NSArray는 바로 저장하고 읽어올 수 있다.
    //저장했던 파일 불러오기
    events.value = eventsArray.flatMap(Event.init)
    //flatMap으로 초기화에 실패하고 nil을 반환한 객체를 걸러낼 수 있다.
    //이전에 불러왔던 정보를 저장하고 불러오므로, 다시 접속해서 정보를 가져올 때까지 테이블 뷰를 유지해 줄 수 있다.
    
    lastModified.value = try? NSString(contentsOf: modifiedFileURL, usedEncoding: nil)
    //지정된 URL에서 데이터를 읽어 NSString으로 반환하고 인코딩한다.
    //저장해 놓은 헤더 값을 이용 해, 그 시간 이후의 새 이벤트만 불러와 성능을 향상 시킬 수 있다.
    
    refresh()
  }

  @objc func refresh() {
    DispatchQueue.global(qos: .background).async { [weak self] in //백그라운드에서 비동기
      guard let strongSelf = self else { return } //self가 nil이면 return
      strongSelf.fetchEvents(repo: strongSelf.repo)
    }
  }

  func fetchEvents(repo: String) { //GitHub 서버로 보낼 URL 요청을 작성한다.
    let response = Observable.from([repo]) //from()은 파라미터로 배열만을 받는다.
    //URLRequest를 직접 작성하는 대신 문자열 생성해 Observable을 유연하게 적용시킬 수 있다.
    //여기서는 repo가 문자열인데, 이 문자열이 바뀌어도 유연하게 대응할 수 있다.
        .map { urlString -> URL in //배열 내부의 각 원소를 URL로 변환
            //여기서 반환형(URL)을 지정해 주지 않아도 타입 추론해서 알아낸다. 가독성을 위해.
            return URL(string: "https://api.github.com/repos/\(urlString)/events")!
            //해당 GitHub의 최신 이벤트에 접근할 수 있다.
        }
        .map { [weak self] url -> URLRequest in //위의 map 연산자 결과로 URLRequest를 생성한다. p.175
            //여기서 반환형(URLRequest)을 지정해 주지 않아도 타입 추론해서 알아낸다. 가독성을 위해.
            var request = URLRequest(url: url)
            
            if let modifiedHeader = self?.lastModified.value { //lastModified에 값이 있으면
                request.addValue(modifiedHeader as String, forHTTPHeaderField: "Last-Modified")
                //헤더 필드에 Last-Modified 값을 추가한다.
            }
            //이렇게 구현을 하면, 트래픽이 줄어들고, 만약 업데이트할 것이 없다면, API 사용한도에 반영되지 않는다.
            
            return request
            //처음 부터 URLRequest를 직접 작성할 수 있다.
        }
        .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
            //flatMap은 Observable을 평탄화한다.
            //일반적으로 변형(transformation) 연산자 체이닝 시에 비동기성을 추가해 주는 데 사용한다.
            //여러 변형 연산자(ex. map)를 연결하면 일반적으로 해당작업은 동기로 진행된다. p.162
            //그러나 flatMap을 삽입해 다음 두 가지 효과를 얻을 수 있다. p.163
            //• 즉시 요소를 emit하고, 완료되는 Observable을 평탄화한다.
            //• 일부 비동기 작업을 수행해 완료될 때까지 Observable을 대기 시킨 이후에 평탄화를 진행한다.
            //  나머지 chain은 계속 작업한다.
            return URLSession.shared.rx.response(request: request)
            //RxCocoa의 response를 사용한다. URL 요청에 대한 Observable응답을 가져 온다.
            //Observable<(response: HTTPURLResponse, data: Data)>를 반환한다.
            //앱이 웹 서버로부터 응답을 받으면 완료된다. //extension으로 custom하게 구현해 줄 수 있다.
            //오류가 발생할 수 있으므로, 사실 catch로 처리해 줘야 한다.
            //rx.response로 구현을 하면, 프로토콜과 delegate 없이 웹 요청을 보내고 응답을 받을 수 있다.
            //위와 같이 map과 flatMap을 혼합하면 선형적이고 비동기적인 코드가 가능해 진다.
        }
        .share(replay: 1, scope: .whileConnected) //웹 요청 결과에 더 많은 구독을 허용하기 위해 공유
        //Observable을 공유하고 마지막으로 내 보낸 이벤트를 버퍼에 보관한다.
        //URLSession.rx.response(request :)는 요청을 서버에 보내고, 응답을 받으면 반환된 데이터와 함께
        //.next 이벤트를 한 번만 내보낸 다음 완료한다.
        //이 상황에서 Observable 항목이 완료된 후 다시 구독하면,
        //새로운 구독이 만들어지고 서버에 대한 또 다른 동일한 요청이 전송된다.
        //이 상황을 방지하기 위해 share()가 아닌 share(replay:, scope:)를 사용한다.
        //마지막 emit된 요소의 버퍼를 유지하고 새로 구독한 모든 옵저버에 피드를 제공한다.
        //따라서 요청이 완료되고 새 옵저버가 공유 시퀀스(share(replay: , scope:))에 등록하면,
        //버퍼에 보관 중인 서버의 응답을 즉시 받게 된다.
        //.whileConnected : 구독자가 없어질 때까지 버퍼를 유지한다.
        //.forever : 버퍼된 요소를 영원히 유지한다. 메모리에 문제를 유발할 수도 있다.
    
        //share(replay: , scope:)는 .complete될 것으로 예상되는 모든 시퀀스에 이 규칙을 사용할 수 있다.
        //그렇게 하면, observable이 다시 생성되는 것을 막을 수 있다.
        //또는 옵저버가 마지막으로 emit된 이벤트를 자동으로 수신하도록 할 때에도 사용할 수 있다.
    
    //응답을 받은 이후의 작업. //URLSession에서 받아온 Data를 JSON으로 변환하는 작업이 필요하다.
    response
        .filter { response, _ in //오류를 걸러 낸다.
            return 200..<300 ~= response.statusCode //상태코드가 200 ~ 300인 응답만 내 보낸다.
            //모두 성공 상태의 코드를 나타낸다.
            //~=는 숫자의 값이 어떤 범위에 포함되어 있는지 검사할 때 쓸 수 있다.
            //왼쪽의 범위가 오른쪽에 있는지 확인한다.
            //https://outofbedlam.github.io/swift/2016/03/08/between-operator/
        }
        .map { _, data -> [[String: Any]] in //여기서는 Data만 의미 있다.
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []), let result = jsonObject as? [[String: Any]] else {
                //응답 받은 json을 [[String: Any]] 타입으로 디코딩 한다. //Dictionary로 변환
                    return []
                    //변환에 실패할 경우 빈 배열을 반환
            }
            
            return result
        }
        .filter { object in //위의 map 연산자에서 json 디코딩이 성공한 경우에만 필터를 통과하게 된다.
            return object.count > 0
        }
        .map { object in //순차적으로 상태 코드에 에러가 없고,
            //json 변환이 제대로 된 경우에만 위의 두 필터를 통과하게 된다.
            //여기서의 map은 Observable의 map 연산자로 각 emit된 요소에서 비 동기적으로 작동한다.
            return object.flatMap(Event.init) //Event.switf의 Event class로 변환
            //map 연산자와 init를 통해 각 요소 별로 이벤트 클래스를 만들어 초기화 시킨다.
            //결국 [[String: Any]] 타입에서 맵을 통해 [Event] 타입이 된다.
            //여기서의 map은 Array의 메서드로 배열 요소를 동기적으로 반복해 초기화한다.
            
            //하지만 map에서 이 방법(Event.init)은 nil인 요소를 걸러 낼 수 없다.
            //map 대신 flatMap을 사용하면 nil인 요소는 걸래 낸다(Swift 라이브러리).
            //http://seorenn.blogspot.kr/2015/09/swift-flatmap.html
            //Event의 이니셜라이저가 init? 이므로 제대로 초기화 되지 않고 nil을 반환한 경우, flatMap으로 제거된다.
        }
        .subscribe(onNext: { [weak self] newEvents in //구독
            self?.processEvents(newEvents) //UI 업데이트
        })
        .disposed(by: bag)
    
    response
        .filter { response, _ in  //오류를 걸러낸다.
            return 200..<400 ~= response.statusCode
            //~=는 숫자의 값이 어떤 범위에 포함되어 있는지 검사할 때 쓸 수 있다.
        }
        .flatMap { response, _ -> Observable<NSString> in
            //flatMap을 사용해 Last-Modified 헤더가없는 응답을 필터링한다. p.174
            guard let value = response.allHeaderFields["Last-Modified"] as? NSString else {
                //allHeaderFields로 모든 헤더 필드를 가져온다.
                //Last-Modified가 HTTP 헤더가 포함되어 있는지 확인
                return Observable.empty() //없으면 빈 Observable 반환
            }
            
            return Observable.just(value) //Last-Modified가 HTTP 헤더가 포함되어 있으면 단일요소 emit
        }
        .subscribe(onNext: { [weak self] modifiedHeader in //구독
            guard let strongSelf = self else { return } //self가 nil이라 옵셔널 바인딩 안되면 종료
            
            strongSelf.lastModified.value = modifiedHeader //lastModified 속성 업데이트
            //최신의 서버 접속 날짜로 업데이트 한다.
            
            try? modifiedHeader.write(to: strongSelf.modifiedFileURL, atomically: true, encoding: String.Encoding.utf8.rawValue) //디스크에 저장
            //NSString을 지정된 URL 위치에 저장한다.
            //Swift string과는 달리 NSString은 내용을 파일로 바로 저장할 수 있다.
            //이미 이전 파일이 있으면 덮어 쓴다.
        })
        .disposed(by: bag)
    
        //Rx를 사용하면, 분리된 작업을 캡슐화할 수 있고, 컴파일 중에 입력 및 출력 유형을 확인하도록 보장할 수 있다.
  }
    
    func processEvents(_ newEvents: [Event]) {
        var updatedEvents = newEvents + events.value //새로 가져온 이벤트를 events.value에 추가한다.
        
        if updatedEvents.count > 50 { //50개의 이벤트만 표시한다.
            updatedEvents = Array<Event>(updatedEvents.prefix(upTo: 50))
            //prefix(upTo: )로 지정된 위치까지의 요소를 가져올 수 있다.
            //50개 이상이 있으면 최신의 50개만 가져온다.
        }
        
        events.value = updatedEvents
        
        DispatchQueue.main.async { //UI 업데이트는 메인 스레드에서 진행되어야 한다.
            //Rx에서 스레드를 관리할 수도 있다.
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing() //테이블 뷰를 기본값으로 재설정하고 spinner를 멈춘다.
            //UIRefreshControl로 pull to refresh를 구현할 수 있다.
            //refreshControl를 talbeView에 subView로 연결시켜 주면 된다.
        }
        
        let eventsArray = updatedEvents.map { $0.dictionary } as NSArray
        //Event 객체의 dictionary요소들로 배열 만든다.
        eventsArray.write(to: eventsFileURL, atomically: true)
        //NSArray의 내용을 지정된 URL 위치에 저장한다.
        //Swift 배열과는 달리 NSArray는 내용을 파일로 바로 저장할 수 있다.
        //이미 이전 파일이 있으면 덮어 쓴다.
    
        //메서드로 UI를 업데이트 하는 대신 변수나 대상에 직접 바인딩 할 수도 있다.
    }

  // MARK: - Table Data Source
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.value.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let event = events.value[indexPath.row]

    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
    cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
    return cell
  }
}

//GitHub에서 JSON APi에서 가져와 표시한다.
//가져온 객체를 디스크에 저장하고 서버에서 최신의 이벤트를 가져오기 전에 테이블에 표시한다.

//URLSession : 웹 URL과 매개변수를 넣은 URLRequest를 만들어 인터넷에 연결하고 응답을 받는다.
//URLSession을 확장하여 사용할 수 있다(RxCocoa-RxSwitf에서 제공된다).
//Podfile을 확인해 보면, RxCocoa도 install되어 있다.
//RxCocoa는 RxSwift를 개발하는데 도움이 되는 API를 구현한다.
//RxJS, RxJava, RxPython 등의 구현에 공유되는 공통 Rx API를 유지하기 위한 모든 추가 기능이 RxCocoa로 분리되어 있다.


