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

class EventsViewController : UIViewController, UITableViewDataSource {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var slider: UISlider!
  @IBOutlet var daysLabel: UILabel!
    
    let events = Variable<[EOEvent]>([])
    let disposeBag = DisposeBag()
    //NSObject의 하위 클래스라면, NSObject+Rx를 사용해, disposeBag가 포함된 클래스를 가져올 수도 있다.
    //여기서는 그냥 default로.
    
    let days = Variable<Int>(360)
    let filteredEvents = Variable<[EOEvent]>([])

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 60
    
    events.asObservable()
        .subscribe(onNext: { [weak self] _ in //구독. //이벤트가 emit 되면 테이블 뷰 리로드
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    //백그라운드 스레드에서 이벤트가 방출 될 수도 있으므로 메인 스레드에서 업데이트가 이루어지도록 하는 것이 좋다.
    //따라 지정하지 않는 한, 구독은 해당 항목을 emit한 스레드를 받는다.
    
    Observable.combineLatest(days.asObservable(), events.asObservable()) { (days, events) -> [EOEvent] in
        //날짜와 이벤트를 결합한다.
        let maxInterval =  TimeInterval(days * 24 * 3600) //인터벌 최대 값. 일수 * 시간 * 초
        
        return events.filter { event in //요청된 날짜 범위의 이벤트만을 가져온다.
            if let date = event.closeDate {
                return abs(date.timeIntervalSinceNow) < maxInterval
            }
            
            return true
        }
    }
    .bind(to: filteredEvents) //새 구독을 만들고 요소를 변수에 보낸다.
    //bind로 source observable을 observer에 연결한다.
    .disposed(by: disposeBag)
    
    filteredEvents.asObservable()
        .subscribe(onNext: { [weak self] _ in
            self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    
    days.asObservable()
        .subscribe(onNext: { [weak self] days in
            self?.daysLabel.text = "Last \(days) days"
        })
        .disposed(by: disposeBag)
  }

  @IBAction func sliderAction(slider: UISlider) {
    days.value = Int(slider.value)
  }
  
  // MARK: UITableViewDataSource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredEvents.value.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventCell
    let event = filteredEvents.value[indexPath.row]
    
    cell.configure(event: event)
    
    return cell
  }
}
