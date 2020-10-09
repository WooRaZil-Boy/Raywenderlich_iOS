/// Copyright (c) 2019 Razeware LLC
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
import Combine

extension UIViewController {
    func alert(title: String, text: String?) -> AnyPublisher<Void, Never> {
        //AnyPublisher<Void, Never>를 반환한다.
        //값을 내보내는 데에는 관심없지만 사용자가 닫기를 탭할때, publisher를 완료한다.
        let alertVC = UIAlertController(title: title, message: text, preferredStyle: .alert)
        
        return Future { resolve in
            alertVC.addAction(UIAlertAction(title: "Close", style: .default) { _ in
                //close 버튼 추가
                resolve(.success(())) //사용자가 탭하면 success로 종료
            })
            
            self.present(alertVC, animated: true, completion: nil)
        }
        .handleEvents(receiveCancel: { //구독이 취소되는 경우
            self.dismiss(animated: true) //해제
        })
        .eraseToAnyPublisher()
    }
}
