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

import Foundation

protocol ModeratorsViewModelDelegate: class {
  func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
  func onFetchFailed(with reason: String)
}

final class ModeratorsViewModel {
  private weak var delegate: ModeratorsViewModelDelegate?
  
  private var moderators: [Moderator] = []
  private var currentPage = 1
  private var total = 0
  private var isFetchInProgress = false
  
  let client = StackExchangeClient()
  let request: ModeratorRequest
  
  init(request: ModeratorRequest, delegate: ModeratorsViewModelDelegate) {
    self.request = request
    self.delegate = delegate
  }
  
  var totalCount: Int {
    return total
  }
  
  var currentCount: Int {
    return moderators.count
  }
  
  func moderator(at index: Int) -> Moderator {
    return moderators[index]
  }
  
  func fetchModerators() {
    guard !isFetchInProgress else {
      return
    }
    //fetch request가 이미 진행 중인 경우 코드를 벗어난다(bail out).
    //이렇게 하면 여러 requests가 발생하는 것을 방지할 수 있다. 나중에 더 자세히 설명한다.
    
    isFetchInProgress = true
    //fetch request가 진행 중이 아니라면, isFetchInProgress를 true로 설정하고 request을 보낸다.
    
    client.fetchModerators(with: request, page: currentPage) { result in
      switch result {
      case .failure(let error):
        DispatchQueue.main.async {
          self.isFetchInProgress = false
          self.delegate?.onFetchFailed(with: error.reason)
        }
        //request가 실패하면 delegate에게 failure 이유를 알리고 사용자에게 특정 alert를 표시한다.
      case .success(let response):
//        DispatchQueue.main.async {
//          self.isFetchInProgress = false
//          self.moderators.append(contentsOf: response.moderators)
//          self.delegate?.onFetchCompleted(with: .none)
//        }
        //성공하면 moderators list에 새로운 items을 추가하고, delegate에게 사용 가능한 데이터가 있음을 알린다.
        
        DispatchQueue.main.async {
          self.currentPage += 1
          self.isFetchInProgress = false
          //response이 성공하면, 검색할 page 번호를 증가시킨다. API request pagination의 기본값은 30개 이다.
          //첫 번째 page를 fetch하면 처음 30개의 items을 검색한다. 두 번째 request에서는 다음 30개를 검색한다.
          //전체 moderators list를 받을 때까지 retrieval mechanism이 계속 된다.
          self.total = response.total
          //서버에서 사용 가능한 총 moderators count를 저장한다.
          //나중에 이 정보를 이용하여 새 page를 request해야 하는지 여부를 결정한다.
          self.moderators.append(contentsOf: response.moderators)
          //새로 반환된 moderators를 저장한다.

          if response.page > 1 {
            //해당 page가 첫 page가 아닌 경우, reload할 index paths를 계산하여 table view content를 update하는 방법을 결정한다.
            let indexPathsToReload = self.calculateIndexPathsToReload(from: response.moderators)
            self.delegate?.onFetchCompleted(with: indexPathsToReload)
          } else {
            self.delegate?.onFetchCompleted(with: .none)
          }
        }
        //전체를 새로고침하는 것이 아닌 새로운 내용만 추가하도록 수정한다.
      }
    }
  }
  
  private func calculateIndexPathsToReload(from newModerators: [Moderator]) -> [IndexPath] {
    let startIndex = moderators.count - newModerators.count
    let endIndex = startIndex + newModerators.count
    return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
  }
}
