//
//  ViewController.swift
//  RxAction
//
//  Created by 근성가이 on 2018. 4. 19..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

enum SharedInput {
    case button(String)
    case barButton
}

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var workingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    var disposableBag = DisposeBag()
    let sharedAction = Action<SharedInput, String> { input in
        switch input {
        case .barButton: return Observable.just("UIBarButtonItem with 3 seconds delay").delaySubscription(3, scheduler: MainScheduler.instance)
        case .button(let title): return .just("UIButton " + title)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Demo: add an action to a button in the view
        let action = CocoaAction { //CocoaAction : rx.action 속성과의 호환 //버튼의 액션을 설정
            print("Button was pressed, showing an alert and keeping the activity indicator spinning while alert is displayed")
            return Observable.create { [weak self] observer -> Disposable in
                // Demo: show an alert and complete the view's button action once the alert's OK button is pressed
                let alertController = UIAlertController(title: "Hello world", message: "This alert was triggered by a button action", preferredStyle: .alert)
                var ok = UIAlertAction.Action("OK", style: .default)
                ok.rx.action = CocoaAction { // UIAlertAction의 action 설정
                    print("Alert's OK button was pressed")
                    observer.onCompleted() //.completed 이벤트를 emit
                    return .empty() //빈 Observable 반환
                }
                alertController.addAction(ok)
                self?.present(alertController, animated: true, completion: nil)
                
                return Disposables.create()
            }
        }
        
        button.rx.action = action //버튼에 Action 연결
        
        // Demo: add an action to a UIBarButtonItem in the navigation item
        self.navigationItem.rightBarButtonItem?.rx.action = CocoaAction {
            print("Bar button item was pressed, simulating a 2 second action")
            return Observable.empty().delaySubscription(2, scheduler: MainScheduler.instance)
            //2초 후 메인 스레드에서 구독
        }
        
        // Demo: observe the output of both actions, spin an activity indicator
        // while performing the work
        Observable.combineLatest( //두 스퀀스에서 최신으로 emit된 값
            button.rx.action!.executing, //executing 현재 실행 중인지 여부
            self.navigationItem.rightBarButtonItem!.rx.action!.executing) { a,b in
                // we combine two boolean observable and output one boolean
                return a || b
            }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] executing in
                // every time the execution status changes, spin an activity indicator
                self?.workingLabel.isHidden = !executing
                if (executing) {
                    self?.activityIndicator.startAnimating()
                }
                else {
                    self?.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: self.disposableBag)
        
        button1.rx.bind(to: sharedAction, input: .button("Button 1"))
        
        button2.rx.bind(to: sharedAction) { _ in
            return .button("Button 2")
        }
        self.navigationItem.leftBarButtonItem?.rx.bind(to: sharedAction, input: .barButton)
        
        sharedAction.executing.debounce(0, scheduler: MainScheduler.instance).subscribe(onNext: { [weak self] executing in
            if (executing) {
                self?.activityIndicator.startAnimating()
            }
            else {
                self?.activityIndicator.stopAnimating()
            }
        })
            .disposed(by: self.disposableBag)
        
        sharedAction.elements.subscribe(onNext: { string in
            print(string  + " pressed")
        })
            .disposed(by: self.disposableBag)
    }
}

extension ViewController {
    func buttonAction() {
        let buttonAction: Action<Void, Void> = Action {
            //Action은 Action<Input, Element>로 정의된 클래스
            //이 버튼은 아무런 데이터를 생성하지 않고 작업을 수행한 후 완료된다.
            print("Doing some work")
            
            return Observable.empty()
        }
        
        button1.rx.action = buttonAction //버튼과 Action을 연결한다. 버튼을 누를 때 마다 작업이 실행된다.
        //        button.rx.action = nil //nil을 연결해 Action을 제거할 수 있다.
    }
    
    func logInAction() {
//        let loginAction: Action<(String, String), Bool> = Action { credentials in //로그인 구현
//            let (login, password) = credentials
//            // loginRequest returns an Observable<Bool>
//
//            return networkLayer.loginRequest(login, password)
//        }
    }
    
    func cellBind() {
//        observable.bind(to: tableView.rx.items) { (tableView: UITableView, index: Int, element: MyModel) in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "buttonCell",
//                                                     for: indexPath)
//            cell.button.rx.action = CocoaAction { [weak self] in
//                // do something specific to this cell here
//                return .empty()
//            }
//            return cell
//
//            }
//            .disposed(by: disposeBag)
        //테이블 뷰에서 셀을 설정할 때, Action을 사용하면, 버튼을 따로 cell의 하위 클래스로 넣지 않아도 구현 가능하다. p.360
    }
    
    func manualExecution() {
//        loginAction
//            .execute(("john", "12345")) //execute(_:)로 수동으로 action을 실행할 수 있다.
//            .subscribe(onNext: {
//                // handle return of action execution here
//            })
//            .disposed(by: disposeBag)
    }
}

//Action은 반응형 응용 프로그램을 만드는 데 사용할 수 있다.
//기본적인 로직은 트리거로 실행되어 작업이 수행되고, 수행할 때 일부의 값이 발생된다(즉시, 나중에 혹은 절대로 X).
//버튼 탭, 타이머, 제스처와 같은 방법으로 구현할 수 있다.
//Action 라이브러리는
//• Observable sequence를 바인딩하기 위해 옵저버를 제공한다. 수동으로 트리거 할 수도 있다.
//• Observable<Bool>을 통해 enabled상태(현재 실행 중인지 여부)를 확인할 수 있다.
//• 작업을 수행/시작 하고 결과를 관찰할수 있도록 Factory의 클로저를 실행할 수 있다.
//• Observable의 결과(flatMap)를 확인할 수 있다.
//• Observable에서 발생하는 오류를 처리한다.
//즉, 오류, 현재 실행 상태, 각 observable의 여부를 표시하고,
//이전 작업이 완료되지 않은 상태에서 새 작업이 시작되지 않도록 보장한다.
//Action은 데이터를 제공하거나 일부만 제공하고 나머지는 완료후 가져올 수도 있다.

//MVVM 패턴을 사용하면, RxSwft와 Action이 매우 적합하다.
//MVVM에서 모든 관찰가능한 Observable을 Action으로 표현할 수 있다.

//https://github.com/RxSwiftCommunity/Action/blob/master/Demo/ViewController.swift





