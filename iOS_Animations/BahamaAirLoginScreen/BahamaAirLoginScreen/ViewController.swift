//
//  ViewController.swift
//  BahamaAirLoginScreen
//
//  Created by 근성가이 on 2017. 1. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

// A delay function
func delay(_ seconds: Double, completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(seconds * 1000.0))) {
        completion()
    }
}

class ViewController: UIViewController {
    // MARK: IB outlets
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var heading: UILabel!
    @IBOutlet var username: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBOutlet var cloud1: UIImageView!
    @IBOutlet var cloud2: UIImageView!
    @IBOutlet var cloud3: UIImageView!
    @IBOutlet var cloud4: UIImageView!
    
    // MARK: further UI
    let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    let status = UIImageView(image: UIImage(named: "banner"))
    let label = UILabel()
    let messages = ["Connecting ...", "Authorizing ...", "Sending credentials ...", "Failed"]
    
    var statusPosition = CGPoint.zero
    var info = UILabel()
    
//    var animationContainerView: UIView!
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up the UI
        loginButton.layer.cornerRadius = 8.0
        loginButton.layer.masksToBounds = true
        
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        loginButton.addSubview(spinner)
        
        status.isHidden = true
        status.center = loginButton.center
        view.addSubview(status)
        
        label.frame = CGRect(x: 0.0, y: 0.0, width: status.frame.size.width, height: status.frame.size.height)
        label.font = UIFont(name: "HelveticaNeue", size: 18.0)
        label.textColor = UIColor(red: 0.89, green: 0.38, blue: 0.0, alpha: 1.0)
        label.textAlignment = .center
        status.addSubview(label)
        
        statusPosition = status.center //애니메이션이 일어남 지점을 저장해 둔다.
        
//        //set up the animation container
//        animationContainerView = UIView(frame: view.bounds)
//        animationContainerView.frame = view.bounds
//        view.addSubview(animationContainerView!)
        
        info.frame = CGRect(x: 0.0, y: loginButton.center.y + 60.0, width: view.frame.size.width, height: 30)
        info.backgroundColor = UIColor.clear
        info.font = UIFont(name: "HelveticaNeue", size: 12.0)
        info.textAlignment = .center
        info.textColor = UIColor.white
        info.text = "Tap on a field and enter username and password"
        view.insertSubview(info, belowSubview: loginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let formGroup = CAAnimationGroup()
        formGroup.duration = 0.5
        formGroup.fillMode = kCAFillModeBackwards
        
        let flyRight = CABasicAnimation(keyPath: "position.x")
        flyRight.fromValue = -view.bounds.size.width/2
        flyRight.toValue = view.bounds.size.width/2
        
        let fadeFieldIn = CABasicAnimation(keyPath: "opacity")
        fadeFieldIn.fromValue = 0.25
        fadeFieldIn.toValue = 1.0
        
        formGroup.animations = [flyRight, fadeFieldIn]
        heading.layer.add(formGroup, forKey: nil)
        
        formGroup.delegate = self
        formGroup.setValue("form", forKey: "name")
        formGroup.setValue(username.layer, forKey: "layer")
        
        formGroup.beginTime = CACurrentMediaTime() + 0.3
        username.layer.add(formGroup, forKey: nil)
        
        formGroup.setValue(password.layer, forKey: "layer")
        formGroup.beginTime = CACurrentMediaTime() + 0.4
        password.layer.add(formGroup, forKey: nil)
        
        //*** CAAnimationGroup으로 대체
//        let flyRight = CABasicAnimation(keyPath: "position.x") //잠재적인 레이어 애니메이션. 데이터 모델일 뿐, 특정 레이어에 종속되어 존재하지 않는다. //각 레이어에서 추가해서 재사용이 가능하다.
//        flyRight.fromValue = -view.bounds.size.width / 2 //fromValue를 설정해야 애니메이션 모델과 레이어를 동기화하는데 복잡성이 줄어든다.
//        flyRight.toValue = view.bounds.size.width / 2 //fromValue가 없는데, 애니메이션에서 레이어의 위치를 수정하면 애니메이션은 화면 중앙에서 시작된다.
//        flyRight.duration = 0.5
//        flyRight.delegate = self
//        flyRight.setValue("form", forKey: "name") //Key - Value 패턴 //필요할 때 (delegate 등) 값을 찾아낼 수 있다.
//        flyRight.setValue(heading.layer, forKey: "layer") //Key - Value 패턴
//        heading.layer.add(flyRight, forKey: nil) //키를 입력해 두면, 나중에 애니메이션을 변경하거나 중단해야 할 경우 식별할 수 있다.
//        
//        flyRight.beginTime = CACurrentMediaTime() + 0.3 //CACurrentMediaTime() :: 현재
//        flyRight.fillMode = kCAFillModeBoth //kCAFillModeRemoved :: 기본값. //kCAFillModeForwards :: 종료 후 마지막 프레임 남아 있음 //kCAFillModeBackwards :: 실행 전 처음 프레임 계속 보임. //kCAFillModeBoth :: kCAFillModeForwards + kCAFillModeForwards //fillMode를 디폴트로 사용하는 것이 좋다. 다른 모드들은 뷰 간의 상호작용이 깨질 우려가 많다.
////        flyRight.isRemovedOnCompletion = false //디폴트가 true 따라서 애니메이션이 완료되면 사라진다. kCAFillModeBoth를 적용시키려면 false로 해야 한다. //애니메이션 자체는 실제로 필드 자체가 애니메이션으로 처리되는 것이 아닌 프레젠테이션 레이어라는 캐시된 레이어(사전 렌더링된 뷰의 이미지)가 애니메이션을 보여주게 된다. 따라서 여기서 설정을 true로 하면 애니메이션 종료 후, 애니메이션이 적용되었던 뷰는 원래 위치에서 보여진다. (원래 위치가 뷰 밖이라면 보여지지 않는다.) //이 속성을 false로 하면 프레젠테이션 레이어가 계속 보여지는 중이므로, 뷰에 대한 작업(텍스트 필드에서 글 입력)을 할 수 없다. -> 애니메이션을 제거하고 실제 텍스트 필드를 위치 시켜야 한다. //isRemovedOnCompletion = false는 화면에 애니메이션이 남아 성능이 저하되므로 특별한 경우가 아니라면 자동으로 제거되고 원래 레이어의 위치를 업데이트 하도록 해야 한다. -> 결과적으로 최종 상태를 유지하는 것처럼 된다.
//        flyRight.setValue(username.layer, forKey: "layer") //이름은 변경하지 않고 레이어에 애니메이션을 추가 할 때마다 레이어 키를 업데이트 한다. -> 델리데이트에서 같은 키를 입력해도 각 애니메이션에 맞는 레이어를 가져온다. //각 레이어마다 새로운 값(beginTime 등)을 설정해 재사용하는 것처럼, CAAnimation 클래스는 모델일 뿐이므로 키 값을 동시에 사용해도 되는 듯?
//        username.layer.add(flyRight, forKey: nil)
//        username.layer.position.x = view.bounds.size.width / 2 //레이어를 애니메이션 종료된 위치로 배치 //레이어 속성을 업데이트하는 경우에는 레이어에 애니메이션을 추가 한 직후에 항상 이를 수행하는 것이 좋다. 때로는 초기 및 최종 애니메이션 값 사이에 이상한 플래시가 나타날 수 있다.
//        
//        flyRight.beginTime = CACurrentMediaTime() + 0.4
//        flyRight.setValue(password.layer, forKey: "layer")
//        password.layer.add(flyRight, forKey: nil)
//        password.layer.position.x = view.bounds.size.width / 2
        
        
        //*** CALayer Animation으로 대체
//        heading.center.x -= view.bounds.width
//        username.center.x -= view.bounds.width
//        password.center.x -= view.bounds.width
        
        //*** CALayer Animation으로 대체
//        cloud1.alpha = 0.0
//        cloud2.alpha = 0.0
//        cloud3.alpha = 0.0
//        cloud4.alpha = 0.0
        
        //*** CAAnimationGroup으로 합침
//        loginButton.center.y += 30.0
//        loginButton.alpha = 0.0
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.0
        fadeIn.toValue = 1.0
        fadeIn.duration = 0.5
//        fadeIn.fillMode = kCAFillModeBackwards //앱이 시작될 때 구름을 숨기려면 fillMode를 kCAFillModeBackwards로 설정해야 한다. //첫 프레임의 alpha가 0이 되기 때문에. 디폴트로 하면 실제 레이어가 보이다가 alpha가 0인 프레젠테이션 컨테이너 레이어가 보이기 때문에 깜빡이는 것처럼 보인다.
        fadeIn.beginTime = CACurrentMediaTime() + 0.5
        cloud1.layer.add(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.7
        cloud2.layer.add(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 0.9
        cloud3.layer.add(fadeIn, forKey: nil)
        
        fadeIn.beginTime = CACurrentMediaTime() + 1.1
        cloud4.layer.add(fadeIn, forKey: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let groupAnimation = CAAnimationGroup() //CAAnimationGroup은 CAAnimation를 상속
        //timingFunction, beginTime, duration, fillMode 등의 세부 사항은 group 전체에서 모두 같이 적용 된다. 따라서 하위의 각 애니메이션에 일일이 설정해 줄 필요 없다.
        groupAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn) //Easing 적용 //일반 UIView Animation의 Easing 옵션들과 비슷 //kCAMediaTimingFunctionLinear :: 전체 애니메이션 동안 동일한 속도 //kCAMediaTimingFunctionEaseIn :: 느리게 시작하여 더 빠른 속도로 종료 //kCAMediaTimingFunctionEaseOut :: 빠르게 시작하여 느리게 종료 //kCAMediaTimingFunctionEaseInEaseOut :: 처음과 끝의 애니메이션은 느리지만 중간은 빠르게 진행 //CAMediaTimingFunction (controlPoints : _ : _ : _ :) 이 메서드로 베지어 곡선을 임의로 만들어서 커스텀한 Easing을 적용할 수 있다.
        groupAnimation.beginTime = CACurrentMediaTime() + 0.5
        groupAnimation.duration = 0.5
        groupAnimation.fillMode = kCAFillModeBackwards
        
        let scaleDown = CABasicAnimation(keyPath: "transform.scale")
        scaleDown.fromValue = 3.5
        scaleDown.toValue = 1.0
        
        let rotate = CABasicAnimation(keyPath: "transform.rotation")
        rotate.fromValue = .pi / 4.0 //45도
        rotate.toValue = 0.0
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.0
        fade.toValue = 1.0
        
        groupAnimation.animations = [scaleDown, rotate, fade]
        loginButton.layer.add(groupAnimation, forKey: nil) //그룹 애니메이션 추가
        
        //*** CALayer Animation으로 대체
//        UIView.animate(withDuration: 0.5) { //즉시 시작. 0.5초 지속
//            self.heading.center.x += self.view.bounds.width
//        }
//        
//        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: { //0.3초 뒤 시작. 0.5초 지속 //하나의 옵션만 있을 경우에는 대괄호를 생략해도 된다. //.repeat :: 계속 반복. //.autoreverse :: .repeat과 연동해서 쓰면 왔다 갔다 계속 반복 //.curveLinear :: 가속이나 감속을 적용하지 않는다. //.curveEaseIn :: 시작 때 가속 //.curveEaseOut :: 끝날 때 감속 //.curveEaseInOut :: 시작할 때 가속, 끝날 때 감속. 디폴트 속성 ?? 이거 레퍼런스랑 설명이 다른데??
//            self.username.center.x += self.view.bounds.width
//        })
//        
//        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
//            self.password.center.x += self.view.bounds.width
//        })
        
        //*** CALayer Animation으로 대체
//        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
//            self.cloud1.alpha = 1.0
//        })
//        
//        UIView.animate(withDuration: 0.5, delay: 0.7, options: [], animations: {
//            self.cloud2.alpha = 1.0
//        })
//        
//        UIView.animate(withDuration: 0.5, delay: 0.9, options: [], animations: {
//            self.cloud3.alpha = 1.0
//        })
//        
//        UIView.animate(withDuration: 0.5, delay: 1.1, options: [], animations: {
//            self.cloud4.alpha = 1.0
//        })

        //*** CAAnimationGroup으로 합침
//        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: { //usingSpringWithDamping :: 스프링 강도. 0.0 ~ 1.0 사이. 값이 높을 수록 딱딱한 애니메이션. //initialSpringVelocity :: 애니메이션의 시작 속도.
//            self.loginButton.center.y -= 30.0
//            self.loginButton.alpha = 1.0
//        })

        //*** CALayer Animation으로 대체
//        animateCloud(cloud1)
//        animateCloud(cloud2)
//        animateCloud(cloud3)
//        animateCloud(cloud4)
        
        animateCloud(layer: cloud1.layer)
        animateCloud(layer: cloud2.layer)
        animateCloud(layer: cloud3.layer)
        animateCloud(layer: cloud4.layer)
        
        let flyLeft = CABasicAnimation(keyPath: "position.x")
        flyLeft.fromValue = info.layer.position.x + view.frame.size.width
        flyLeft.toValue = info.layer.position.x
        flyLeft.duration = 5.0
//        flyLeft.repeatCount = 2.5 //정수가 아니어도 된다. //반복 시간을 정의 하려면 repeatDuration을 사용한다. //정수로 하면, 애니메이션이 종료 된 후에 레이블 위치인 중간으로 튀어 버린다. -> 0.5를 더해 주면 중간에서 멈춘다.
//        flyLeft.autoreverses = true
//        flyLeft.speed = 2.0 //5초로 설정되어 있더라도 속도가 2배 이므로 2.5초 만에 애니메이션이 끝난다.
//        info.layer.speed = 2.0 //레이어의 속도도 바꿀 수 있다. //해당 레이어의 모든 애니메이션 속도에 영향을 준다. -> 여기에선 정보를 표시하는 레이어 애니메이션 이 2 X 2 = 4배의 속도로 실행된다.
//        view.layer.speed = 2.0 //여기선 모든 애니메이션 2배, 위의 옵션과 같이 넣어두면 정보 애니메이션은 8배가 된다. //-> 레이어 속도는 왠만하면 쓰지 않는 편이 낫다.
        info.layer.add(flyLeft, forKey: "infoappear") //Key - Value. 델리게이트에서 값을 찾아 정지할 수 있도록.
        
        let fadeLabelIn = CABasicAnimation(keyPath: "opacity")
        fadeLabelIn.fromValue = 0.2
        fadeLabelIn.toValue = 1.0
        fadeLabelIn.duration = 4.5
        info.layer.add(fadeLabelIn, forKey: "fadein") //동일한 레이어에서 서로 독립적으로 여러 애니메이션을 실행할 수 있다. //애니메이션을 동기화해야하는 경우에는 animation groups을 사용할 수 있다.
        
        username.delegate = self
        password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: further methods
extension ViewController {
    @IBAction func login() {
        view.endEditing(true)
        
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.bounds.size.width += 80.0
        }, completion: { _ in
            self.showMessage(index: 0)
        })
        
        UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginButton.center.y += 60.0
            //*** CALayer Animation으로 대체
//            self.loginButton.backgroundColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
            self.spinner.center = CGPoint(x: 40.0, y: self.loginButton.frame.size.height/2)
            self.spinner.alpha = 1.0
        })
        
        let tintColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
        tintBackgroundColor(layer: loginButton.layer, toColor: tintColor)
        roundCorners(layer: loginButton.layer, toRadius: 25.0)
        
        let balloon = CALayer()
        balloon.contents = #imageLiteral(resourceName: "balloon").cgImage
        balloon.frame = CGRect(x: -50.0, y: 0.0, width: 50.0, height: 65.0)
        view.layer.insertSublayer(balloon, below: username.layer)
        
        let flight = CAKeyframeAnimation(keyPath: "position")
        flight.duration = 12.0
        flight.values = [CGPoint(x: -50.0, y: 0.0),
                         CGPoint(x: view.frame.width + 50.0, y: 160.0),
                         CGPoint(x: -50.0, y: loginButton.center.y)
                        ].map { NSValue(cgPoint: $0) } //map으로 한번에 NSValue로 박싱 -> CGPoint를 바로 values에 적용하면 작동하지 않는다. NSValue로 박싱이 꼭 필요하다.
        flight.keyTimes = [0.0, 0.5, 1.0]
        balloon.add(flight, forKey: nil)
        balloon.position = CGPoint(x: -50.0, y: loginButton.center.y) //레이어 속성을 업데이트하는 경우에는 레이어에 애니메이션을 추가 한 직후에 항상 이를 수행하는 것이 좋다.
    }
    
    func showMessage(index: Int) {
        label.text = messages[index]
        
        UIView.transition(with: status, duration: 0.33, options: [.curveEaseOut, .transitionCurlDown], animations: { //그냥 animate랑 차이 있음 //transition은 3D 스타일 애니메이션을 만드는 유일한 방법으로 복잡한 애니메이션을 만들 때 더 중요한 메서드.
            self.status.isHidden = false
        }, completion: { _ in
            delay(2.0, completion: {
                if index < self.messages.count - 1 {
                    self.removeMessage(index: index)
                } else {
                    self.resetForm()
                }
            })
        })
        
        
        //그냥 animate로 하려면 isHidden이 아니라 alpha값을 변경해 줘야 한다. (처음 초기화 때 0.0, 애니메이션 주면서 1.0) //transition이 아니기 때문에 애니메이션 옵션에 transitionCurlDown이 적용되지 않는다.
//        UIView.animate(withDuration: 0.33, delay: 0.0, options: [.curveEaseOut, .transitionCurlDown], animations: {
//            self.status.isHidden = false
//        })
        
        
        //        //create new view
        //        let newView = UIImageView(image: #imageLiteral(resourceName: "banner"))
        //        newView.center = animationContainerView.center
        
        //        //add the new view nua transition
        //        UIView.transition(with: animationContainerView, duration: 0.33, options: [.curveEaseOut, .transitionFlipFromBottom], animations: { //애니메이션과 비슷. 설정한 뷰가 애니메이션의 컨터이너 뷰로 사용 //.transitionFlipFromBottom은 경첩처럼 아래 가장자리에서 부터 뒤집어짐.
        //            self.animationContainerView.addSubview(newView)
        //        })
        
        //        //remove the view via transition
        //        UIView.transition(with: self.animationContainerView, duration: 0.33, options: [.curveEaseOut, .transitionFlipFromBottom], animations: {
        //            newView.removeFromSuperview()
        //        })
        
        //        //hide the view via transition
        //        UIView.transition(with: newView, duration: 0.33, options: [.curveEaseOut, .transitionFlipFromBottom], animations: {
        //            newView.isHidden = true
        //        }, completion: nil)
        
        //        //replace via transition
        //        UIView.transition(from: oldView, to: newView, duration: 0.33, options: .transitionFlipFromBottom)
    }
    
    func removeMessage(index: Int) {
        UIView.animate(withDuration: 0.33, delay: 0.0, options: [], animations: { //단순히 뷰 밖으로 보내는 것이기에 transition이 아닌 animate써도 무방
            self.status.center.x += self.view.frame.size.width
        }, completion: { _ in //초기화 해 준다.
            self.status.isHidden = true
            self.status.center = self.statusPosition
            
            self.showMessage(index: index + 1)
        })
    }
    
    func resetForm() {
        UIView.transition(with: status, duration: 0.2, options: .transitionCurlUp, animations: { //option이 하나 일 때는 배열 쓰지 않아도 된다. //초기화
            self.status.isHidden = true
            self.status.center = self.statusPosition
        })
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: { //초기화
            self.spinner.center = CGPoint(x: -20.0, y: 16.0)
            self.spinner.alpha = 0.0
            //*** CALayer Animation으로 대체
//            self.loginButton.backgroundColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
            self.loginButton.bounds.size.width -= 80.0
            self.loginButton.center.y -= 60.0
        }, completion: { _ in
            let tintColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
            tintBackgroundColor(layer: self.loginButton.layer, toColor: tintColor)
            roundCorners(layer: self.loginButton.layer, toRadius: 10.0)
        })
        
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation") //UIView KeyframeAnimation은 서로 독립적인 애니메이션을 결합하는 방식이지만(중간에 겹치거나 틈이 생길 수 있다.) //CAKeyframeAnimation은 특정 레이어의 단일 속성에 적용할 수 있다. 지점을 지정하여 모든 애니메이션이 연결되서 실행되며 겹치거나 틈이 생길 수 없다.
        wobble.duration = 0.25
        wobble.repeatCount = 4
        wobble.values = [0.0, -.pi/4.0, 0.0, .pi/4.0, 0.0] //-45° == π / 4
        wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
        heading.layer.add(wobble, forKey: nil)
    }
    
    //*** CALayer Animation으로 대체
//    func animateCloud(_ cloud: UIImageView) {
//        let cloudSpeed = 60.0 / view.frame.size.width //구름들의 속도는 모두 일정
//        let duration = (view.frame.size.width - cloud.frame.origin.x) * cloudSpeed //처음 위치를 구해 속도를 곱해준다. //처음 위치가 좌측에 있을 수록 오래도록 보이게 된다.
//        
//        UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: .curveLinear, animations: { //.curveLinear 선형으로 움직인다
//            cloud.frame.origin.x = self.view.frame.size.width //지정된 시간 만큼 뷰의 끝까지 이동 //x값이므로 뷰의 넓이과 같게 되면(지정된 시간만큼이 시간이 지난 후) 뷰에서 사라진다
//        }, completion: { _ in //애니메이션이 완료가 되면
//            cloud.frame.origin.x = -cloud.frame.size.width //구름의 우측이 뷰의 좌측에 맞닿는 위치로 이동
//            self.animateCloud(cloud) //애니메이션 다시 시작
//        })
//    }
    
    func animateCloud(layer: CALayer) {
        let cloudSpeed = 60.0 / Double(view.layer.frame.size.width)
        let duration: TimeInterval = Double(view.layer.frame.size.width - layer.frame.origin.x) * cloudSpeed
        
        let cloudMove = CABasicAnimation(keyPath: "position.x")
        cloudMove.duration = duration
        cloudMove.toValue = self.view.bounds.width + layer.bounds.width / 2
        cloudMove.delegate = self
        cloudMove.setValue("cloud", forKey: "name")
        cloudMove.setValue(layer, forKey: "layer")
        layer.add(cloudMove, forKey: nil)
        
    }
}

//MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //이거 UITextFieldDelegate 아님..
        let nextField = (textField === username) ? password : username
        nextField?.becomeFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(info.layer.animationKeys()) //애니메이션 키들을 프린트 //애니메이션이 종료된 이후에는 nil. 실행 중에만 키 값을 리턴한다.
        info.layer.removeAnimation(forKey: "infoappear")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.characters.count < 5 {
            let jump = CASpringAnimation(keyPath: "position.y")
            jump.fromValue = textField.layer.position.y + 1.0
            jump.toValue = textField.layer.position.y
            jump.initialVelocity = 100.0 //시작 시간. 지속시간을 계산하기 전에 설정해줘야 제대로 된 시간을 계산한다. //음수를 지정할 수도 있다. 음수는 방향이 반대. //양수 값을 높일 수록 오래 지속되지만, 그 만큼 흔들리는 범위도 커진다.
            jump.mass = 10.0 //대다는 물건의 무게. 값이 높을 수록 애니메이션이 오래 지속되지만, 그 만큼 흔들리는 범위도 커진다.
            jump.stiffness = 1500.0 //스프링 강도. 높을수록 적게 흔들리고 지속시간이 짧아진다.
            jump.damping = 50.0 //흔들리는 범위?
            jump.duration = jump.settlingDuration
            textField.layer.add(jump, forKey: nil)
            
            //사실 위의 스프링 애니메이션은 UIView로도 할 수 있지만, 밑의 레이에 자체에 효과를 주는 것은 CALater에서만 할 수 있다.
            textField.layer.borderWidth = 3.0
            textField.layer.borderColor = UIColor.clear.cgColor
            
            let flash = CASpringAnimation(keyPath: "borderColor") //꼭 이동이 아니라 색 변화 등의 애니메이션에도 Spring을 적용할 수 있다.
            flash.damping = 7.0
            flash.stiffness = 200.0
            flash.fromValue = UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0).cgColor
            flash.toValue = UIColor.white.cgColor
            flash.duration = flash.settlingDuration
            textField.layer.add(flash, forKey: nil)
        }
    }
    
    
}

//MARK: - CAAnimationDelegate
extension ViewController: CAAnimationDelegate { //뷰 애니메이션은 중단하거나 실행 중 액서스를 할 수 있는 방법이 없다. //이와 달리 CAAnimation은 실행 중인 애니메이션을 검사하거나 중지할 수 있다. //CABasicAnimation은 CAAnimation의 하위 클래스. 델리게이트를 설정할 수 있다.
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print("animation did finish")
        
        guard let name = anim.value(forKey: "name") as? String else { //value(forKey: ) 는 항상 AnyObject를 반환하므로 사용 시에 캐스팅 해 줘야 한다.
            return
        }
        
        if name == "form" {
            let layer = anim.value(forKey: "layer") as? CALayer
            anim.setValue(nil, forKey: "layer") //원본 레이어에 대한 참조 제거
            
            //*** CASpringAnimation으로 대체
//            let pulse = CABasicAnimation(keyPath: "transform.scale")
//            pulse.fromValue = 1.25
//            pulse.toValue = 1.0
//            pulse.duration = 0.25
//            layer?.add(pulse, forKey: nil) //옵셔널 체이닝. 레이어 값을 가져오지 못했다면 애니메이션이 적용되지 않는다.
            
            let pulse = CASpringAnimation(keyPath: "transform.scale") //CASpringAnimation은 CABasicAnimation의 서브 클래스 //UIView의 usingSpringWithDamping는 지속시간과 초기 속도, 강도 정도만 설정할 수 있다면, CASpringAnimation은 훨씬 많은 옵션들을 적용할 수 있다. //지속시간은 설정 할 수 없다. CABasicAnimation의 프로퍼티로 지정해 줄 수는 있지만, 그러면 스프링 애니메이션이 제대로 작동하지 않고 지속시간 만큼만 적용되고 끊겨버린다. //디폴트 값 들 :: damping: 10.0, mass: 1.0, stiffness: 100.0, initialVelocity: 0.0
            pulse.damping = 7.5 //값이 높을 수록 지속 시간이 줄어든다.
            pulse.fromValue = 1.25
            pulse.toValue = 1.0
            pulse.duration = pulse.settlingDuration //settlingDuration은 스프링 애니메이션이 적용되고 안정화되기까지의 시간
            layer?.add(pulse, forKey: nil) //옵셔널 체이닝. 레이어 값을 가져오지 못했다면 애니메이션이 적용되지 않는다.
        }
        
        if name == "cloud" { //??뭔가 끊기는 느낌이 드는데??
            if let layer = anim.value(forKey: "layer") as? CALayer {
                anim.setValue(nil, forKey: "layer")
                layer.position.x = -layer.bounds.width / 2
                
                delay(0.5, completion: {
                    self.animateCloud(layer: layer)
                })
            }
        }
    }
}

//MARK: - Top Level
func tintBackgroundColor(layer: CALayer, toColor: UIColor) {
    //*** CASpringAnimation으로 대체
//    let tint = CABasicAnimation(keyPath: "backgroundColor")
//    tint.fromValue = layer.backgroundColor
//    tint.toValue = toColor.cgColor
//    tint.duration = 0.5
//    
//    layer.add(tint, forKey: nil)
//    layer.backgroundColor = toColor.cgColor //레이어 속성을 업데이트하는 경우에는 레이어에 애니메이션을 추가 한 직후에 항상 이를 수행.
    
    let tint = CASpringAnimation(keyPath: "backgroundColor")
    tint.damping = 5.0
    tint.initialVelocity = -10.0
    tint.fromValue = layer.backgroundColor
    tint.toValue = toColor.cgColor
    tint.duration = tint.settlingDuration
    layer.add(tint, forKey: nil)
    layer.backgroundColor = toColor.cgColor
}

func roundCorners(layer: CALayer, toRadius: CGFloat) {
    let round = CABasicAnimation(keyPath: "cornerRadius")
    round.fromValue = layer.cornerRadius
    round.toValue = toRadius
    round.duration = 0.5
    
    layer.add(round, forKey: nil)
    layer.cornerRadius = toRadius //레이어 속성을 업데이트하는 경우에는 레이어에 애니메이션을 추가 한 직후에 항상 이를 수행.
}

