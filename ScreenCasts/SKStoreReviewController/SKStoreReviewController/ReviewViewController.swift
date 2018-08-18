///// Copyright (c) 2018 Razeware LLC
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

//1. Import StoreKit
import StoreKit //SKStoreReviewController 사용을 위해 import

class ReviewViewController: UIViewController {
  
  let userDefaults = UserDefaults.standard
  
  let entriesKey = "numberOfEntries"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //3. Keep track of the times we've visited this screen to limit the number of review requests
    let currentFinishCount = userDefaults.integer(forKey: entriesKey)
    userDefaults.set(currentFinishCount + 1, forKey: entriesKey)
    //1년에 3번만 보여줄 수 있기 때문에, display되는 시점을 잡는 것이 매우 중요하다.
  }
  
  @IBAction func submitButtonTouched(_ sender: Any)
  {
    //4. If the number of entries has exceed a certain threshold, ask for a review.  For something fitness related, this number might be 100, so that 3 times a year, you can request a review.  Otherwise, iOS will determine when the review prompt gets generated
    if userDefaults.integer(forKey: entriesKey) > 2 {
      //여기에서는 테스트를 위해 2번으로 제한했지만, 실제 앱의 경우에는 100 이상의 높은 값으로 해줘야 할 것이다.
      
      //2. Request a review.  This will always happen in development, never in TestFlight, and only sometimes in release!
      SKStoreReviewController.requestReview()
      //SKStoreReviewController의 리뷰 뷰를 호출한다.
      
      //5. Reset the counter.
      userDefaults.set(0, forKey: entriesKey) //리셋
    }
  }
}


//SKStoreReviewController
//iOS 10.3 부터 도입. 한 사용자에 1년에 3번만 보여질 수 있다.
//TestFlight에서는 제대로 작동하지 않는다.
