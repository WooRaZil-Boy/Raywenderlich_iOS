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

class MainViewController: UIViewController {

  @IBOutlet weak var imagePreview: UIImageView!
  @IBOutlet weak var buttonClear: UIButton!
  @IBOutlet weak var buttonSave: UIButton!
  @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    private let bag = DisposeBag()
    //DisposeBag이 뷰 컨트롤러 소유이므로, 뷰 컨트롤러 해제 시 모든 observables을 삭제할 수 있다.
    //이렇게 구현하면 subscriptions가 컨트롤러 할당 해제와 함께 폐기되므로 메모리 관리가 쉬워진다. p.84
    //실제로 이 앱은 MainViewController가 root이고, 모든 로직이 이 위에서 동작하므로 해제되진 않는다.
    private let images = Variable<[UIImage]>([]) //빈 이미지 배열로 생성
    //Variable은 value 속성으로 일반 변수처럼 사용할 수 있다.
    //private로 접근 권한을 지정해 주는 것이 좋다. //이 뷰 컨트롤러 내에서만 사용할 것이므로 private

  override func viewDidLoad() {
    super.viewDidLoad()
    
    images.asObservable() //BehaviorSubject 가져오기
        .subscribe(onNext: { [weak self] photos in //.next 이벤트만 구독
            //.next 이벤트(여기서는 이미지 추가)가 발생할 때마다 이 핸들러 클로저가 실행된다.
            //BehaviorSubject이므로 버튼을 누르기 전에 초기화한 상태에서 한번 호출 된다.
            guard let preview = self?.imagePreview else { return }
            
            preview.image = UIImage.collage(images: photos, size: preview.frame.size)
            //콜라주 helper 메서드
            //delegate나 다른 설정 없이도, 해당 요소에 변화가 생길 때 마다 실행된다.
        })
        .disposed(by: bag)
    
    images.asObservable() //BehaviorSubject 가져오기
        .subscribe(onNext: { [weak self] photos in //.next 이벤트만 구독
            //.next 이벤트(여기서는 이미지 추가)가 발생할 때마다 이 핸들러 클로저가 실행된다.
            //BehaviorSubject이므로 버튼을 누르기 전에 초기화한 상태에서 한번 호출 된다.
            self?.updateUI(photos: photos)
            //UI업데이트
            //Rx의 모든 시퀀스는 비동기이므로 메인 스레드 차단 여부를 걱정할 필요 없다.

        }) //각 로직에 맞춰 여러 구독을 만들 수 있다. //위의 구독에 updateUI를 추가해 한 곳에서 관리할 수도 있다.
        .disposed(by: bag)
    
  }
  
  @IBAction func actionClear() { //이미지 초기화
    images.value = [] //요소로 들어 있던 시퀀스들은 모두 dispose
  }

  @IBAction func actionSave() {
    //Traits를 사용하여 Observable을 더 직관적으로 코드를 짤 수 있다.
    //• Single : .success(value), .error 이벤트 중 하나를 emit한다. .success(value)는 .next와 .complete 이벤트의 조합.
    //여기에서는 .sucess(assetId) 혹은 .error(NotFound)가 된다. //성공해 값을 산출하거나 실패하는 일회성 프로세스에 유용하다.
    //observable을 구독 한 이후, asSingle()를 사용하여 Single로 변환하거나 Single.create()으로 직접 만들 수 있다.
    
    //• Maybe : .success(value), .completed, .error 세 가지 이벤트가 있다.
    //여기에서는 .sucess(assetId), completed, .error(NotFound)가 된다. //성공, 실패의 여부가 있고 선택적으로 성공한 값을 반환해야 할때.
    //observable을 구독 한 이후, asMaybe()를 사용하여 Maybe로 변환하거나 Maybe.create()으로 직접 만들 수 있다.
    
    //• Completable : .completed, .error 이벤트가 있다.
    //여기에서는 completed, .error(NotFound)가 된다. //성공, 실패의 여부만 중요한 경우
    //observable이 값을 emit할 수 있으므로 Completable는 변환할 수 없고, 직접 Completable.create()으로 직접 만들어야 한다.
    //사용자가 작업하는 동안 앱이 문서를 자동 저장하는 경우, 저장이 완료되면 알림으로 알려주는 식으로 구현해 줄 수 있다.
    //saveDocument()
    //    .andThen(Observable.from(createMessage)) //andThen 연산자로
    //    .subscribe(onNext: { message in
    //        message.display()
    //    }, onError: {e in
    //        alert(e.localizedDescription)
    //    })
    guard let image = imagePreview.image else { return }
    
    PhotoWriter.save(image) //이미지 저장 //Observable<String>을 반환한다.
        .asSingle() //Observable을 Single trait로 변환
        //save 메서드는 한 번의 .next()를 발생하고 종료되거나, .erorr로 종료된다. 따라서 Single trait를 사용하기 좋다.
        //Single trait는 .success(value), .error 이벤트 중 하나를 emit한다.
        .subscribe(onSuccess: { [weak self] id in //성공할 경우
            self?.showMessage("Saved with id: \(id)")
            self?.actionClear()
            }, onError: { [weak self] error in //error
                self?.showMessage("Error", description: error.localizedDescription)
        })
        .disposed(by: bag)
  }

  @IBAction func actionAdd() { //이미지 추가
//    images.value.append(UIImage(named: "IMG_1907.jpg")!) //Variable의 현재 값 변경
//    //Variable은 value에 할당된 모든 값에 대해 시퀀스를 자동 생성한다.
//    //배열에 요소가 추가될 때마다 Observable(시퀀스)의 .next() 이벤트 발생된다.
    
    let photosViewController = storyboard!.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
    photosViewController.selectedPhotos
        .subscribe(onNext: { [weak self] newImage in //.next 이벤트만 구독
            //사진을 선택 했을 때 next 이벤트가 발생하므로, 해당 이벤트를 받아와 로직을 추가해 줄 수 있다.
            //selectedPhotos를 구독했으므로 photosViewController에서 사진을 선택했을 때,
            //클로저 내의 내용이 실행된다.
            guard let images = self?.images else { return }
            
            images.value.append(newImage) //Variable에 추가
        }, onDisposed: { //bag 객체가 해제될 때 error, completed를 통해 종료 될 때 호출
            //여기에서는 MainViewController가 해제되거나, photos 시퀀스를 완료하지 않으므로 해당 메모리가 해제되지 않는다.
            print("completed photo selection")
        })
        .disposed(by: bag)
    //delegate 대신, 해당 Subject에 이벤트 발생했을 경우의 로직을 넣어준다.
    navigationController!.pushViewController(photosViewController, animated: true)
    //보통의 iOS 구현에서는 delegate 패턴으로 포토 라이브러리에서 선택한 이미지를 다시 받아와야 한다.
    //그러나 Rx에서는 Observable로 객체를 주고 받을 수 있으므로 따로 delegate를 정의할 필요 없다.
    //Observable은 하나 혹은 다수의 Observer에게 모든 종류의 메시지를 전달할 수 있기 때문이다.
    //Subject = Observable + Observer
  }

  func showMessage(_ title: String, description: String? = nil) {
    let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { [weak self] _ in self?.dismiss(animated: true, completion: nil)}))
    present(alert, animated: true, completion: nil)
  }
    
    private func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0 //사진이 짝수 개 일때만 저장
        buttonClear.isEnabled = photos.count > 0 //선택된 사진 없을 때 클리어 비활성화
        itemAdd.isEnabled = photos.count < 6 //사진 수 6개로 제한
        title = photos.count > 0 ? "\(photos.count) photos" : "Collage" //제목 변경
    }
}


