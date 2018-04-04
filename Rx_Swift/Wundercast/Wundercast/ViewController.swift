/*
 * Copyright (c) 2014-2016 Razeware LLC
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

class ViewController: UIViewController {

  @IBOutlet weak var searchCityName: UITextField!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var humidityLabel: UILabel!
  @IBOutlet weak var iconLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
    
    let bag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    style()
    
    //더미 //테스트용
    ApiController.shared.currentWeather(city: "RxSwift")
        .observeOn(MainScheduler.instance)
        //observeOn : 지정된 스케줄러에서 옵저버 콜백을 실행하기 위해 소스 시퀀스를 래핑
        //특정 작업의 스케줄러를 변경할 수 있다.
        .subscribe(onNext: { data in
            self.tempLabel.text = "\(data.temperature)° C"
            self.iconLabel.text = data.icon
            self.humidityLabel.text = "\(data.humidity)%"
            self.cityNameLabel.text = data.cityName
        })
        .disposed(by: bag) //추가해 줘야 한다.
        //구독은 필요할 때 취소하는 일회용 개체를 반환환다. 이것을 컨트롤러가 닫힐 때 취소해 줘야 한다.
        //.disposed(by: )를 추가해 주면, 컨트롤러가 해제될 때마다 구독이 취소되고 처리가 된다.
        //리소스의낭비를 막을 수 있을 뿐만 아니라 예기치 않은 에러 등에도 대응할 수 있다.
    
    
    
    
    //Basic
//    searchCityName.rx.text //ControlProperty는 ObservableType과 ObserverType을 모두 준수한다.
//        //따라서 객체를 구독하고 새 값을 emit 할 수 있다.
//        .filter { ($0 ?? "").characters.count > 0 }
//        //currentWeather는 파라미터로 nil이나 빈 값을 허용하지 않는다. 필터링
//        .flatMap { text in
//            //searchCityName.rx의 입력된 text로 currentWeather를 호출해 데이터를 가져온다.
//            return ApiController.shared.currentWeather(city: text ?? "Error")
//                .catchErrorJustReturn(ApiController.Weather.empty)
//            //catchErrorJustReturn : 에러가 발생 했을 때 설정해둔 단일 이벤트를 전달한다.
//            //subscribe에서 에러를 감지하는 것이 아닌, Observable에서 에러에 대한 기본 이벤트를 설정하는 연산자.
//            //오류가 발생하면, Observable이 종료 된다. 하지만, 그러면 앱이 더 이상 진행이 안 되기 때문에,
//            //오류가 나더라도 빈 Observable을 반환해 앱이 계속 작동하도록 한다.
//            //catchErrorJustReturn를 주석 처리하면, 처음 한 글자를 치자 마자
//            //404 에러가 나면서 종료된서 서버와 더 이상 통신하지 않는다.
//        }
//        .observeOn(MainScheduler.instance)
//        //지정된 스케줄러에서 옵저버 콜백을 실행하기 위한 소스 시퀀스를 래핑한다.
//        //동작하는 스케줄러를 MainScheduler로 전환해 준다. //UI 업데이트 위한 메인 스레드와 MainScheduler로 전환
//        .subscribe(onNext: { data in //필터링과 flatMap에서 에러가 안 난 경우에만 observeOn를 거쳐 구독된다.
//            self.tempLabel.text = "\(data.temperature)° C"
//            self.iconLabel.text = data.icon
//            self.humidityLabel.text = "\(data.humidity)%"
//            self.cityNameLabel.text = data.cityName
//        })
//        .disposed(by:bag)
//    //구독은 필요할 때 취소하는 일회용 개체를 반환환다. 이것을 컨트롤러가 닫힐 때 취소해 줘야 한다.
//    //.disposed(by: )를 추가해 주면, 컨트롤러가 해제될 때마다 구독이 취소되고 처리가 된다.
//    //리소스의낭비를 막을 수 있을 뿐만 아니라 예기치 않은 에러 등에도 대응할 수 있다.
    
    
    
    
    //Binding
//    let search = searchCityName.rx.text
//        //ControlProperty는 ObservableType과 ObserverType을 모두 준수한다.
//        //따라서 객체를 구독하고 새 값을 emit 할 수 있다.
//        .filter { ($0 ?? "").characters.count > 0 }
//        //currentWeather는 파라미터로 nil이나 빈 값을 허용하지 않는다. 필터링
//        .flatMapLatest { text in
//            //searchCityName.rx의 입력된 text로 currentWeather를 호출해 데이터를 가져온다.
//            //flatMapLatest은 flatMap의 최신 요소를 emit 한다.
//            //flatMapLatest는 결과를 재사용 가능하게 만들고 일회용 데이터 소스를 다중 사용 가능한 Observable로 변환
//            //Observable은 Rx의 재사용 가능한 엔티티가 될 수 있다.
//            return ApiController.shared.currentWeather(city: text ?? "Error")
//                .catchErrorJustReturn(ApiController.Weather.empty)
//            //catchErrorJustReturn : 에러가 발생 했을 때 설정해둔 단일 이벤트를 전달한다.
//            //subscribe에서 에러를 감지하는 것이 아닌, Observable에서 에러에 대한 기본 이벤트를 설정하는 연산자.
//            //오류가 발생하면, Observable이 종료 된다. 하지만, 그러면 앱이 더 이상 진행이 안 되기 때문에,
//            //오류가 나더라도 빈 Observable을 반환해 앱이 계속 작동하도록 한다.
//            //catchErrorJustReturn를 주석 처리하면, 처음 한 글자를 치자 마자
//            //404 에러가 나면서 종료된서 서버와 더 이상 통신하지 않는다.
//        }
//        .shareReplay(1)
//        //기본 시퀀스에 대해 단일 구독을 공유하는 Observable을 반환하고 구독 즉시 버퍼의 최대 요소 수까지 재생
//        .observeOn(MainScheduler.instance)
//        //지정된 스케줄러에서 옵저버 콜백을 실행하기 위한 소스 시퀀스를 래핑한다.
//        //동작하는 스케줄러를 MainScheduler로 전환해 준다. //UI 업데이트 위한 메인 스레드와 MainScheduler로 전환
//
//    //위의 결과로 search에는 문자열을 반환하는 observable이 생성 된다. 각각의 필요한 정보를 바인딩 한다.
//    search.map { "\($0.temperature)° C" }
//          .bind(to:tempLabel.rx.text) //바인딩
//        //RxCocoa의 바인딩은 단방향 데이터 스트림이다. 앱의 데이터 흐름을 크데 단순화 시킬 수 있다.
//        //단방향 바인딩에서 Receiver는 값을 반환할 수 있다. 양방향에서는 가능하지만 코드가 매우 복잡해진다.
//        //기본적으로 bind(to: )로 바인딩 할 수 있으며, Receiver가 ObserverType이어야 한다.
//        //Subject는 UILabel, UITexField, UIImageView 등의 요소의
//        //변경 가능한 데이터를 get, set할 수 있어 매우 중요하다.
//        //바인딩은 그 목적 외에도 백그라운드 작업 트리거로 사용할 수 있다.
//        //요약하자만 bind 연산자는 subscribe()의 특별한 버전이다.
//          .disposed(by:bag)
//        //구독은 필요할 때 취소하는 일회용 개체를 반환환다. 이것을 컨트롤러가 닫힐 때 취소해 줘야 한다.
//        //.disposed(by: )를 추가해 주면, 컨트롤러가 해제될 때마다 구독이 취소되고 처리가 된다.
//        //리소스의낭비를 막을 수 있을 뿐만 아니라 예기치 않은 에러 등에도 대응할 수 있다.
//
//    //이전에는 전체 UI를 업데이트 하는 하나의 Observable을 가져왔지만, 바인딩 된 블록 별로 업데이트 한다.
//    //코드 재사용이 쉬워지고, 가독성이 좋아진다.
//    search.map { $0.icon }
//      .bind(to:iconLabel.rx.text)
//      .disposed(by:bag)
//
//    search.map { "\($0.humidity)%" }
//      .bind(to:humidityLabel.rx.text)
//      .disposed(by:bag)
//
//    search.map { $0.cityName }
//      .bind(to:cityNameLabel.rx.text)
//      .disposed(by:bag)
    
    
    
    
    //Traits
//    //RxCocoa를 이용하여, bind 외에도 UI와 함께 사용되는 특수한 Observables(Traits)을 구현해 줄 수 있다.
//    //Trait는 다음과 같은 특성이 있다.
//    //• Trait는 오류를 일으킬 수 없다.
//    //• 메인 스케줄러(main scheduler)에서 observed 된다.
//    //• 메인 스케줄러(main scheduler)를 subscribe 한다.
//    //• side effects를 공유한다.
//    //따라서 사용자 인터페이스에서 항상 표시되는 항목과 사용자 인터페이스에서 항상 처리할 수 있는 항목을 보장한다.
//    //Trait는 ControlProperty, ControlEvent, Driver로 구성된다.
//    //• ControlProperty는 ObservableType과 ObserverType을 모두 준수한다. rx를 extention해
//    //  인터페이스 구성 요소에 데이터를 바인딩하기 위해 사용한다.
//    //• ControlEvent는 UI 구성 요소의 특정 이벤트를 수신하는 데 사용된다. (ex. 키보드의 Return 키 입력)
//    //• Driver는 특별한 observable로, 오류가 발생하지 않는다. 모든 프로세스가 메인 스레드에서 실행되어
//    //  백 그라운드 스레드에서 UI를 변경하는 것을 피할 수 있다.
//    //Traits은 선택적인 부분으로 사용하지 않아도 무방하다. UI업데이트에 규칙을 추가하는 데 유용하게 사용할 수 있다.
//    let search = searchCityName.rx.text
//        //ControlProperty는 ObservableType과 ObserverType을 모두 준수한다.
//        //따라서 객체를 구독하고 새 값을 emit 할 수 있다.
//        .filter { ($0 ?? "").characters.count > 0 }
//        //currentWeather는 파라미터로 nil이나 빈 값을 허용하지 않는다. 필터링
//        .flatMapLatest { text in
//            //searchCityName.rx의 입력된 text로 currentWeather를 호출해 데이터를 가져온다.
//            //flatMapLatest은 flatMap의 최신 요소를 emit 한다.
//            //flatMapLatest는 결과를 재사용 가능하게 만들고 일회용 데이터 소스를 다중 사용 가능한 Observable로 변환
//            //Observable은 Rx의 재사용 가능한 엔티티가 될 수 있다.
//            return ApiController.shared.currentWeather(city: text ?? "Error")
//                .catchErrorJustReturn(ApiController.Weather.empty)
//            //catchErrorJustReturn : 에러가 발생 했을 때 설정해둔 단일 이벤트를 전달한다.
//            //subscribe에서 에러를 감지하는 것이 아닌, Observable에서 에러에 대한 기본 이벤트를 설정하는 연산자.
//            //오류가 발생하면, Observable이 종료 된다. 하지만, 그러면 앱이 더 이상 진행이 안 되기 때문에,
//            //오류가 나더라도 빈 Observable을 반환해 앱이 계속 작동하도록 한다.
//            //catchErrorJustReturn를 주석 처리하면, 처음 한 글자를 치자 마자
//            //404 에러가 나면서 종료된서 서버와 더 이상 통신하지 않는다.
//        }
//        .asDriver(onErrorJustReturn: ApiController.Weather.empty) //Driver trait로 전환
//        //onErrorJustReturn로 오류 발생 시 사용할 기본 값 지정.
//        //• asDriver (onErrorDriveWith :) : 오류를 수동으로 처리한다.
//        //• asDriver (onErrorRecover :) : 오류 복구를 위드 메서드
//
//    search.map { "\($0.temperature)° C" }
//      .drive(tempLabel.rx.text) //bind를 drive로 바꿔 준다. 메인 스레드에서만 호출할 수 있다.
//        //드라이버의 기능을 활용하면서 올바른 UI 업데이트가 보장된다. bind(to: )와 매우 비슷하다.
//      .disposed(by:bag)
//
//    search.map { $0.icon }
//      .drive(iconLabel.rx.text)
//      .disposed(by:bag)
//
//    search.map { "\($0.humidity)%" }
//      .drive(humidityLabel.rx.text)
//      .disposed(by:bag)
//
//    search.map { $0.cityName }
//      .drive(cityNameLabel.rx.text)
//      .disposed(by:bag)

    
    
    
    //Final
    let search = searchCityName.rx.controlEvent(.editingDidEndOnExit)
        //이전 버전들은 너무 많은 리소스를 사용하고, 문자를 입력할 때마다 request를 발생시켜 API를 요청하므로
        //이벤트가 있을 때에만 실행 시켜 주는 것이 좋다.
        //코드는 Trait에 의해 컴파일 타임에 제어된다.
        .asObservable() //Observable 전환
        .map { self.searchCityName.text } //텍스트로 변환
        .flatMap { text in
            //searchCityName.rx의 입력된 text로 currentWeather를 호출해 데이터를 가져온다.
            //flatMapLatest은 flatMap의 최신 요소를 emit 한다.
            //flatMapLatest는 결과를 재사용 가능하게 만들고 일회용 데이터 소스를 다중 사용 가능한 Observable로 변환
            //Observable은 Rx의 재사용 가능한 엔티티가 될 수 있다.
            return ApiController.shared.currentWeather(city: text ?? "Error")
            //버튼을 누를 때만 검색하므로 .catchErrorJustReturn(ApiController.Weather.empty)를
            //제거해 주고, 구독(여기서는 asDriver)에서 관리해 주면 된다.
        }
        .asDriver(onErrorJustReturn: ApiController.Weather.empty) //Driver trait로 전환
        //onErrorJustReturn로 오류 발생 시 사용할 기본 값 지정.
        //• asDriver (onErrorDriveWith :) : 오류를 수동으로 처리한다.
        //• asDriver (onErrorRecover :) : 오류 복구를 위드 메서드
    
    search.map { "\($0.temperature)° C" }
        .drive(tempLabel.rx.text) //bind를 drive로 바꿔 준다. 메인 스레드에서만 호출할 수 있다.
        //드라이버의 기능을 활용하면서 올바른 UI 업데이트가 보장된다. bind(to: )와 매우 비슷하다.
        .disposed(by:bag)
    
    search.map { $0.icon }
        .drive(iconLabel.rx.text)
        .disposed(by:bag)
    
    search.map { "\($0.humidity)%" }
        .drive(humidityLabel.rx.text)
        .disposed(by:bag)
    
    search.map { $0.cityName }
        .drive(cityNameLabel.rx.text)
        .disposed(by:bag)
    
  }

 override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    Appearance.applyBottomLine(to: searchCityName)
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Style

  private func style() {
    view.backgroundColor = UIColor.aztec
    searchCityName.textColor = UIColor.ufoGreen
    tempLabel.textColor = UIColor.cream
    humidityLabel.textColor = UIColor.cream
    iconLabel.textColor = UIColor.cream
    cityNameLabel.textColor = UIColor.cream
  }
}

//ApiController에서 ViewController로 Data를 보내는 구조 (단일 방향 데이터 흐름)

//ViewController가 해제될 때, 구독을 처리하는 DisposeBag.
//코드를 보면 각 클로저 내부에 weak이나 unowned를 쓰지 않았다. 이 앱은 ViewController가 하나이므로 생명주기가 같다.
//하지만, 다중의 ViewController를 사용하는 앱이라면, weak 또는 unowned로 강한 참조를 막아야 한다.
//Rx에서 이를 사용하는 지침은
//• nothing : 싱글톤이거나 절대로 메모리 해제 되지 않는 뷰 컨트롤러 내부에서 사용(ex. rootViewController)
//• unowned : 클로저 작업 수행 후, 메모리가 해제되는 뷰 컨트롤러 내부에서 사용
//• weak : 이 외의 모든 경우
//EXC_BAD_ACCESS 오류를 방지한다.

//p.258

