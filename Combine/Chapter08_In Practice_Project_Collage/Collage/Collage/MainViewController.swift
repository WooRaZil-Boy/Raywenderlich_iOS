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

import Combine //Combine을 가져온다.
import UIKit

class MainViewController: UIViewController {
  
  // MARK: - Outlets

  @IBOutlet weak var imagePreview: UIImageView! {
    didSet {
      imagePreview.layer.borderColor = UIColor.gray.cgColor
    }
  }
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!

  // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    //현재 뷰 컨트롤러의 라이프 사이클에 연결된 UI 구독을 저장하는 집합
    //UI컨트롤을 바인딩할 때 이러한 구독을 현재 뷰 컨트롤러의 수명주기에 연결하는 것이 일반적이다.
    //뷰 컨트롤러가 네비게이션 스택에서 pop되거나 해제되는 경우 모든 UI 구독을 즉시 취소할 수 있다.
    private var images = CurrentValueSubject<[UIImage], Never>([])
    //PassthroughSubject 대신 CurrentValueSubject를 사용하는 것이 좋다.
    //CurrentValueSubject를 사용하면, 구독시 최소 하나의 값이 전송되고 UI가 정의되지 않는 상태를 가지지 않는다.
    //따라서 잘못된 상태가 되더라도 초기값을 기다릴 필요가 없다.

  // MARK: - View controller
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let collageSize = imagePreview.frame.size
    
    images //현재 사진 모음에 대한 구독을 시작한다.
        .handleEvents(receiveOutput: { [weak self] photos in
            self?.updateUI(photos: photos) //updateUI를 실행한다.
        })
        .map { photos in //단일 콜라주로 변환한다.
            //photos는 [UIImage]. 계속 이미지가 추가 되도, CurrentValueSubject는 배열 하나뿐이다.
            UIImage.collage(images: photos, size: collageSize)
            //UIImage+Collage.swift에 정의되어 있는 헬퍼 메서드
        }
        .assign(to: \.image, on: imagePreview)
        //콜라주 이미지를 imagePreview.image로 바인딩한다.
        .store(in: &subscriptions) //저장
        //뷰 컨트롤러의 수명주기에 연결하여 메모리관리를 할 수 있게 한다.
  }
  
  private func updateUI(photos: [UIImage]) {
    buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
    buttonClear.isEnabled = photos.count > 0
    itemAdd.isEnabled = photos.count < 6
    title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
  
  // MARK: - Actions
  
  @IBAction func actionClear() {
    images.send([])
    //images subject를 통해 빈 배열을 보낸다.
    //모든 구독자에게 전달된다.
  }
  
  @IBAction func actionSave() {
    guard let image = imagePreview.image else { return }
    
    PhotoWriter.save(image) //반환값인 future를 구독한다.
        .sink(receiveCompletion: { [unowned self] completion in
            if case .failure(let error) = completion { //failure와 함께 완료되는 경우
                self.showMessage("Error", description: error.localizedDescription)
                //오류 메시지 표시
            }
            self.actionClear()
        }, receiveValue: { [unowned self] id in //저장된 이미지의 식별자를 가져올 수 있는 경우
            self.showMessage("Saved with id: \(id)")
            //성공 메시지 표시
        })
        .store(in: &subscriptions) //저장
  }
  
  @IBAction func actionAdd() {
//    let newImages = images.value + [UIImage(named: "IMG_1907.jpg")!]
//    //IMG_1907.jpg 이미지를 현재 images의 배열 값에 추가한다.
//    images.send(newImages)
//    //subject를 통해 모든 구독자가 이를 수신한다.
    
    let photos = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    //스토리보드에서 PhotosViewController를 인스턴스화한다.
    
    photos.$selectedPhotosCount //구독
        //@Published와 $를 사용해 해당 속성을 간단하게 publisher로 만들 수 있다.
        //didSet이랑 비슷하게 사용할 수 있다.
        .filter { $0 > 0 }
        .map { "Selected \($0) photos" }
        .assign(to: \.title, on: self) //view controller의 title에 바인딩
        .store(in: &subscriptions) //저장
    
    let newPhotos = photos.selectedPhotos
        .prefix(while: { [unowned self] _ in
            return self.images.value.count < 6
            //6개 미만이면 구독을 유지한다.
        })
        .filter { newImage in //Challenges
            return newImage.size.width > newImage.size.height
            //세로 방향 이미지를 필터링한다.
        }
        .share() //여러 구독이 publisher를 공유해야 하는 경우, share()를 사용해 준다.
    
    photos.selectedPhotos //Challenges
        .filter { [unowned self] _ in self.images.value.count == 5 }
        //선택한 현재 이미지의 개수가 5인 경우에만 방출된 값을 전달한다.
        //즉, 현재 6번째 이미지를 추가하고 있음을 의미한다.
        .flatMap { [unowned self] _ in
            self.alert(title: "Limit reached", text: "To add more than 6 photos please purchase Collage Pro")
            //최대 사진수에 도달했음을 알리는 알림 표시
        }
        .sink(receiveValue: { [unowned self] _ in
            self.navigationController?.popViewController(animated: true)
            //뷰 컨트롤러 뒤로 이동
        })
        .store(in: &subscriptions) //저장
    //콜라주에 대한 최대 사진 수를 선택하는 경우 photos view controller를 해제하고 main view controller로 돌아간다.
    
    
    
    
    
    
    
    
    
//    let newPhotos = photos.selectedPhotos //구독한다.
//    let newPhotos = photos.selectedPhotos.share()
      newPhotos
        .map { [unowned self] newImage in
            return self.images.value + [newImage]
            //선택한 이미지의 현재 목록을 가져와서 새 이미지를 추가한다.
        }
        .assign(to: \.value, on: images)
        //images subject의 value에 업데이트된 이미지 배열을 할당한다.
        .store(in: &subscriptions) //저장
        //subscriptions에 저장하면, 해당 뷰 컨트롤러를 닫을 때마다 구독이 종료된다.
    
    newPhotos
        .ignoreOutput()
        //방출된 값을 무시하고, 구독자에게 완료 이벤트만 제공한다.
        .delay(for: 2.0, scheduler: DispatchQueue.main)
        //주어진 시간을 기다린다.
        //"X photos selected"라는 기존 메시지가 나타나고, 2초 후에 실제로 선택한 총 사진의 개수를 보여준다.
        .sink(receiveCompletion: { [unowned self] _ in
            self.updateUI(photos: self.images.value)
            //컨트롤러의 title을 업데이트 한다.
        }, receiveValue: { _ in })
        .store(in: &subscriptions) //저장
    
    navigationController!.pushViewController(photos, animated: true)
    //해당 뷰 컨트롤러를 navigation stack으로 push한다.
  }
  
  private func showMessage(_ title: String, description: String? = nil) {
//    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
//    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { alert in
//      self.dismiss(animated: true, completion: nil)
//    }))
//    present(alert, animated: true, completion: nil)
    
    //Combine Future로 변경
    alert(title: title, text: description)
        .sink(receiveValue: { _ in })
        .store(in: &subscriptions) //저장
  }
}
