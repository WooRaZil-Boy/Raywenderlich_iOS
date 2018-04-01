/*
 * Copyright (c) 2016 Razeware LLC
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

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet var tableView: UITableView!
    
    let categories = Variable<[EOCategory]>([])
    //Variable : BehaviorSubject를 래핑. 현재값을 상태로 유지하고 최신/초기 값만 구독자에게 알린다.
    //BehaviorSubject를 더 쉽게 사용하기 위한 래핑. 초기값이 필요하다.
    let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    categories
        .asObservable()
        .subscribe(onNext: { [weak self] _ in //구독
            //categories의 값이 변할 때 실행(테이블 뷰 리로드) 되는데
            //startDownload에서 EONET.categories를 할당하면서, request가 실행되고 카테고리의 값들을 가져온다.
            //그 후 바인딩 되어 있는 값이 들어오면서 테이블 뷰 리로드
            DispatchQueue.main.async { //스케줄러로 대체할 수 있다.
                self?.tableView?.reloadData()
            }
        })
        .disposed(by: disposeBag)

    startDownload()
  }

  func startDownload() {
    let eoCategories = EONET.categories //모든 카테고리의 배열 다운로드
    let downloadedEvents = eoCategories.flatMap { categories in //해당 카테고리의 지난 해 이벤트 다운로드
        return Observable.from(categories.map { category in
            EONET.events(forLast: 360, category: category)
        })
    }
    .merge(maxConcurrent: 2) //최대 구독 수를 제한해 준다.
    
//    let updatedCategories = Observable
//        .combineLatest(eoCategories, downloadedEvents) { (categories, events) -> [EOCategory] in
//            //다운로드한 카테고리를 다운로드 한 이벤트와 결합해 이벤트가 추가된 업데이트 카테고리 목록을 만든다. p.209
//            return categories.map { category in
//                var cat = category
//                cat.events = events.filter { //각 요소(카테고리)에서 해당하는 것만 필터링한다. //id로 필터링
//                    $0.categories.contains(category.id)
//                    //해당 이벤트는 여러 카테고리에 속할 수 있으므로 일치하는 모든 이벤트를 추가한다.
//                }
//
//                return cat
//            }
//        }
    
    let updatedCategories = eoCategories.flatMap { categories in
        downloadedEvents.scan(categories) { updated, events in //scan은 중간 값을 emit한다.
            return updated.map { category in //p.218
                let eventsForCategory = EONET.filteredEvents(events: events, forCategory: category) //카테고리의 이벤트
                
                if !eventsForCategory.isEmpty {
                    var cat = category
                    cat.events = cat.events + eventsForCategory
                    
                    return cat
                }
                
                return category
            }
        }
    }
    
    eoCategories
        .concat(updatedCategories) //합치기
        .bind(to: categories) //새 구독을 만들고 요소를 변수에 보낸다.
        //bind로 source observable(EONET.categories)을 observer(categories 값)에 연결한다.
        .disposed(by: disposeBag)
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
    let category = categories.value[indexPath.row]
    
    cell.textLabel?.text = "\(category.name) (\(category.events.count))"
    cell.accessoryType = (category.events.count > 0) ? .disclosureIndicator: .none
    //Variable은 내부적으로 잠기기 때문에 백그라운드 스레드에서 업데이트가 되어도 안전하다.
    
    return cell
  }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories.value[indexPath.row]
        
        if !category.events.isEmpty {
            let eventsController = storyboard!.instantiateViewController(withIdentifier: "events") as! EventsViewController
            eventsController.title = category.name
            eventsController.events.value = category.events
            //eventsController의 events 변수에 Observable이 구독되어 있으므로
            //eventsController의 events 변수에 값을 설정하면 테이블 뷰가 자동으로 업데이트 된다.
            
            navigationController!.pushViewController(eventsController, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
  
}

//카테고리를 디스크에 저장해 새로운 데이터를 가져올 때까지 사용한다.
