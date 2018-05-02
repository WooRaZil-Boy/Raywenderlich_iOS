/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import RealmSwift

class StatsViewController: UIViewController {

  @IBOutlet var statsLabel: UILabel!
    
    private var messagesToken: NotificationToken? //Realm 알림 토큰
    //ViewController가 메모리 해제되면, 토큰 또한 해제된다.

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let realm = try! Realm()
    let messages = realm.objects(Message.self) //모든 Message 객체를 가져온다
    
    messagesToken = messages.observe { [weak self] _ in //알림 구독
        //새 Message가 추가될 때 마다 트리거 된다.
        guard let this = self else { return }
        
        UIView.transition(with: this.statsLabel, duration: 0.33, options: [.transitionFlipFromTop], animations: {
            this.statsLabel.text = "Total messages: \(messages.count)"
        }, completion: nil)
        //플립 애니메이션으로 statsLabel 업데이트
    }
  }
}

//이렇게 구현하면 reactive app이 된다. p.131
//• DB polling 대신, 데이터의 변경에 반응한다.
//• write 코드가 read와 완전히 분리되어 있으므로 메시지 기반 아키텍처를 사용한다.
//• Stats Screen은 DB에 저장된 메시지 수에 관계없이 유사한 퍼포멘스를 보여준다.
//• write 트랜잭션은 백 그라운드 큐에서 수행되므로, UI를 블락시키지 않는다.
