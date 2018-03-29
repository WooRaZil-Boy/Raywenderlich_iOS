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
    private var imageCache = [Int]() //이미지의 크기를 바이트로 저장(같은 이미지인지 확인하기 위해)
    //원래는 이미지 데이터 또는 Asset의 URL 해시를 저장해야 한다. 여기서는 간단히 이미지의 크기로 비교.

  override func viewDidLoad() {
    super.viewDidLoad()
    
    images.asObservable() //BehaviorSubject 가져오기
        .throttle(0.5, scheduler: MainScheduler.instance)
        //throttle(_ : scheduler :)는 지정된 시간 간격 내에 다른 요소가 뒤 따라 들어오면 요소를 필터링한다. p.140
        //여기서는 하나의 사진을 탭하고, 0.5초 이내에 또 다시 사진을 탭하면, 첫 번째 요소를 걸러 내고, 두 번째 요소만 필터링한다.
        //물론 여러개를 연속해서 빠르게 탭해도(0.5초 이낸 반복) 마지막 요소만 필터링하고, 이전 요소는 걸러낸다.
        //시간 기반 연산자는 스케줄러를 사용한다. MainScheduler.instance는 앱의 메인 스레드에서 코드를 실행하는 공유 스케줄러이다.
        
        //여기서는 새로운 사진을 탭하는 순간, 콜라주를 제작하는데, 여러 장의 사진을 빠르게 누르는 경우가 있을 수 있다.
        //짧은 시간에 일어나는 여러 개의 이벤트 중 마지막 것만을 걸러 가져오게 된다. //근데 왜 필터링 하는 지 모르겠음. 메모리 때문에?
        //같은 사진 여러번 누르는 경우는 imageCache로 걸러 낸다.
        //이중 탭을 제거하거나, 사용자가 손가락을 조금씩 움직이고 있는 경우 마지막 맘추는 이벤트만 가져올 수 있다.
        //즉, 너무 많은 입력이 짧은 시간에 계속될 경우 throttle()을 유용하게 활용할 수 있다.
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
    imageCache = [] //캐시 배열을 비워준다.
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
    let newPhotos = photosViewController.selectedPhotos
        .share() //share 연산자로 구독을 공유할 수 있다. 버퍼의 요소를 즉시 재생한다.
        //첫 장에서 본 loop 예제처럼, 이전 구독의 값이 다른 구독에 영향을 미친다. p.125
        //여러 개의 구독이 하나의 Observable에서 공유된다.
        //Share는 구독자가 0에서 1로 변경된 경우에만 구독을 만든다. 그 이후, 다른 구독자가 생기면 share는 이미 만든 구독을 공유한다.
        //모든 구독자이 해제 되어 disposed되면 공유 시퀀스도 해제된다.
        //share()는 구독 전에 emit된 값을 제공하지 않지만, share(replay : scope :)는 가장 최근에 emit된 값을 옵저버에게 전달해 줄 수 있다.
        //PublishSubject, BehaviorSubject 처럼
        //share는 아직 완료되지 않은 Observable에서 사용하거나, 완료 후 새로 구독 되지 않는다는 것이 보장되면 공유가 안정적이다.
        //이 뒤에 만들어진 newPhotos 객체를 각각 subscribe해서 해당 로직을 완성하면 된다.
    
    newPhotos //share()로 공유 된다.
        .takeWhile { [weak self] image in
            //takeWhile은 skipWhile의 반대이다. p.113 //지정된 조건이 true인 경우 이벤트가 발생하고, 처음 false가 나오면 그 때부터 skip 된다.
            return (self?.images.value.count ?? 0) < 6 //self?.images.value.count이 없을 때는 default로 0이 되도록
            //PhotoPickerViewController에서 사진 갯수를 제한 건다.
            //MainViewController에서는 6개가 넘어가면 버튼이 비활성화 되도록 해뒀지만 PhotoViewController에서는 따로 제약이 없다.
        }
        .filter { newImage in //onNext 이벤트 전에 필터링 조건을 줘서 필요한 요소만 이벤트를 줄 수 있다.
            return newImage.size.width > newImage.size.height //가로가 세로보다 더 큰 이미지만 필터링한다.
            //세로가 긴 이미지는 콜라주를 만들 때 비율이 맞지 않기 때문에 버그처럼 보일 수 있다.
        }
        .filter { [weak self] newImage in //onNext 이벤트 전에 필터링 조건을 줘서 필요한 요소만 이벤트를 줄 수 있다. //이미지가 고유한 것인지 확인
            //Observables는 현재 상태 또는 값을 제공해 주지 않는다. 따라서 방출 된 요소의 고유성을 확인하려면 직접 코드로 구현해 줘야 한다.
            //이미지 데이터 또는 Asset의 URL 해시를 저장하는 것이 좋은 방법이지만, 여기서는 간단히 이미지의 크기로 비교.
            let len = UIImagePNGRepresentation(newImage)?.count ?? 0
            //UIImagePNGRepresentation() : PNG 포맷의 데이터로 반환. //count로 이미지의 바이트를 알아낼 수 있다.
            
            guard self?.imageCache.contains(len) == false else { //이미 캐싱된 이미지라면 false
                return false
            }
            
            self?.imageCache.append(len) //새 이미지일 경우, 고유한 id로(여기서는 바이트) 캐싱한다.
            
            return true //중복 되는 이미지를 여러번 추가했을 경우 한 번만 추가되게 된다.
        }
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
    
    newPhotos //사용자가 사진을 선택할 때마다, UIImage 요소를 내보낸다. //share()로 공유 된다.
        .ignoreElements() //필터링 //.next는 무시 되나, completed와 error는 허용한다. 다이어그램 p.104
        .subscribe(onCompleted: { [weak self] in //ignoreElements이 완료 이벤트만 받으므로 여기서 작업 //구독
            self?.updateNavigationIcon()
            //이미지가 추가되서 바뀌는 로직은 넘기고 오직 최종 완료되는 이벤트에서만 updateNavigationIcon()를 실행한다.
        })
        .disposed(by: bag)
    
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
    
    private func updateNavigationIcon() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal) //지정된 렌더링 모드로 새 이미지 객체 생성
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: .done, target: nil, action: nil)
        //좌측 상단에 바 버튼을 업데이트 한다.
    }
}

//단순히 observable을 여러 번 호출하는 것으론 아무런 일도 일어나지 않는다. 실제로 subscribe해야 한다.
//그러기 위해, observable은 구독 시마다 클로저를 생성한다.



