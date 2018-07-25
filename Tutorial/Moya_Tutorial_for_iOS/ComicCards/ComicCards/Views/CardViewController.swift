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
import UIKit
import Kingfisher
import Moya

class CardViewController: UIViewController {
  // - MARK: - Dependencies
  private var comic: Comic?
  
  private let provider = MoyaProvider<Imgur>()
  //Moya의 Target과 상호작용할 때, 기본적으로 MoyaProvider 클래스를 사용한다.
  private var uploadResult: UploadResult? //업로드 결과 저장

  // - MARK: - Outlets
  @IBOutlet weak private var lblTitle: UILabel!
  @IBOutlet weak private var lblDesc: UILabel!
  @IBOutlet weak private var lblChars: UILabel!
  @IBOutlet weak private var lblDate: UILabel!
  @IBOutlet weak private var image: UIImageView!
  @IBOutlet weak private var card: UIView!
  @IBOutlet weak private var progressBar: UIProgressView!
  @IBOutlet weak private var viewUpload: UIView!

  @IBOutlet weak private var btnShare: UIButton!
  @IBOutlet weak private var btnDelete: UIButton!

  private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "MMM dd, yyyy"

    return df
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let comic = comic else { fatalError("Please pass in a valid Comic object") }

    layoutCard(comic: comic)
  }
}

// MARK: - Imgur handling
extension CardViewController {
  private func layoutCard(comic: Comic) {
    lblTitle.text = comic.title
    lblDesc.text = comic.description ?? "Not available"
    
    if comic.characters.items.isEmpty {
      lblChars.text = "No characters"
    } else {
      lblChars.text = comic.characters.items
        .map { $0.name }
        .joined(separator: ", ")
    }
    
    lblDate.text = dateFormatter.string(from: comic.onsaleDate) //날짜 설정
    image.kf.setImage(with: comic.thumbnail.url)
    //Kingfisher로 이미지 로드. 웹 이미지 로드 라이브러리
  }

  @IBAction private func uploadCard() {
    UIView.animate(withDuration: 0.15) {
      self.viewUpload.alpha = 1.0
      self.btnShare.alpha = 0.0
      self.btnDelete.alpha = 0.0
    }

    progressBar.progress = 0.0
    
    let card = snapCard() //Image 생성
    
    provider.request(.upload(card), //Provider에서 upload와 관련된 Endpoint 호출
                     callbackQueue: DispatchQueue.main, //업로드 진행 시 업데이트 받을 큐 //여기서는 main
                     progress: { [weak self] progress in
                      //업로드 시 진행률을 progress로 반환한다. 이를 활용해 진행상황을 표시해 준다.
                      self?.progressBar.setProgress(Float(progress.progress), animated: true)
      }, completion: { [weak self] response in
        guard let self = self else { return }
        //이전 버전에서는 weakSerf = self 등으로 해 줘야 했지만, Xcode 10부터는 self로 가능
        
        UIView.animate(withDuration: 0.15) { //request 완료.
          self.viewUpload.alpha = 0.0
          self.btnShare.alpha = 0.0
          //업로드 뷰와 공유 버튼 숨기기
        }
        
        switch response { //response의 성공과 실패에 따른 추가 작업들을 해 준다.
        case .success(let result):
          do {
            let upload = try result.map(ImgurResponse<UploadResult>.self)
            //업로드 결과 저장
            
            self.uploadResult = upload.data
            self.btnDelete.alpha = 1.0
 
            self.presentShare(image: card, url: upload.data.link) //공유 완료 alert
          } catch {
            self.presentError()
          }
        case .failure: //실패 시
          self.presentError()
        }
    })
  }

  @IBAction private func deleteCard() {
    guard let uploadResult = uploadResult else { return }
    btnDelete.isEnabled = false
    //uploadResult를 사용할 수 있는 지 홧인하고 삭제 버튼을 비활성화하여 사용자가 탭하지 않도록 한다.
    
    provider.request(.delete(uploadResult.deletehash)) { [weak self] response in
      //Provider에 delete Endpoint에 대한 Task를 실행한다.
      //deletehash로 업로드된 이미지를 고유하게 식별한다.
      guard let self = self else { return }
      
      let message: String
      
      //삭제의 성공, 실패에 따른 메시지 출력
      switch response {
      case .success:
        message = "Deleted successfully!"
        self.btnDelete.alpha = 0.0
      case .failure:
        message = "Failed deleting card! Try again later."
        self.btnDelete.isEnabled = true
      }
      
      let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Done", style: .cancel))
      
      self.present(alert, animated: true)
    }
  }
}

// MARK: - Helpers
extension CardViewController {
  static func instantiate(comic: Comic) -> CardViewController {
    guard let vc = UIStoryboard(name: "Main", bundle: nil)
      .instantiateViewController(withIdentifier: "ComicViewController") as? CardViewController else { fatalError("Unexpectedly failed getting ComicViewController from Storyboard") }

    vc.comic = comic

    return vc
  }

  private func presentShare(image: UIImage, url: URL) {
    let alert = UIAlertController(title: "Your card is ready!", message: nil, preferredStyle: .actionSheet)

    let openAction = UIAlertAction(title: "Open in Imgur", style: .default) { _ in
      UIApplication.shared.open(url)
    }

    let shareAction = UIAlertAction(title: "Share", style: .default) { [weak self] _ in
      let share = UIActivityViewController(activityItems: ["Check out my iMarvel card!", url, image],
                                           applicationActivities: nil)
      share.excludedActivityTypes = [.airDrop, .addToReadingList]
      self?.present(share, animated: true, completion: nil)
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    alert.addAction(openAction)
    alert.addAction(shareAction)
    alert.addAction(cancelAction)

    present(alert, animated: true, completion: nil)
  }

  private func presentError() {
    let alert = UIAlertController(title: "Uh oh", message: "Something went wrong. Try again later.",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

    present(alert, animated: true, completion: nil)
  }

  private func snapCard() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(card.bounds.size, true, UIScreen.main.scale)
    card.layer.render(in: UIGraphicsGetCurrentContext()!)
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError("Failed snapping card") }
    UIGraphicsEndImageContext()

    return image
  }
}
