//
//  ViewController.swift
//  BullsEye
//
//  Created by 근성가이 on 2017. 12. 20..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore //Core Animation은 QuartzCore 안에 있다.

//앱은 사용자가 종료해야 종료가 된다. 대기 상태로 있으면서 이벤트를 기다리고, 이벤트가 발생하면 처리한 후 다시 대기 모드로 들어간다.
//하나의 화면은 하나의 뷰 컨트롤러를 가지고 있는 것이 좋다. 
//Warning이 프로그램 실행에 영향을 끼치지는 않지만 왠만하면 warning도 제거해라.

//가로모드일 경우 상태표시 줄을 숨기는 것이 좋다. //Project Settings - Deployment Info - Hide status bar
class ViewController: UIViewController {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!
    
    var currentValue = 0 //viewDidLoad에서 초기화 하므로 값은 큰 의미 없다. //보통 0으로 초기화
    var targetValue = 0 //Instance scope
    var score = 0 //유형을 추정한다. //alt키를 누른채(물음표 상태에서) 마우스를 클릭하면 타입 정보를 확인할 수 있다.
    //종종 변수를 상수와 구분하기 위해 _score으로 표현하기도 한다.
    var round = 0

    override func viewDidLoad() { //ViewController가 인터페이스를 스토리보드에서 로드한 직후 "한 번만" 실행된다. //초기값 설정에 적절
        super.viewDidLoad()
        
        //Slider 이미지 세팅
//        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")!
        slider.setThumbImage(#imageLiteral(resourceName: "SliderThumb-Normal"), for: .normal) //직접 이름으로 이미지 객체를 만들지 않고도 이런 식으로 표현할 수 있다.
        
//        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")!
        slider.setThumbImage(#imageLiteral(resourceName: "SliderThumb-Highlighted"), for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
//        let trackLeftImage = UIImage(named: "SliderTrackLeft")!
        let trackLeftResizable = #imageLiteral(resourceName: "SliderTrackLeft").resizableImage(withCapInsets: insets)
        slider.setMinimumTrackImage(trackLeftResizable, for: .normal)
        
//        let trackRightImage = UIImage(named: "SliderTrackRight")!
        let trackRightResizable = #imageLiteral(resourceName: "SliderTrackRight").resizableImage(withCapInsets: insets)
        slider.setMaximumTrackImage(trackRightResizable, for: .normal)
        
        startNewGame()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func showAlert() { //IBAction으로 스토리보드와 연결시켜 준다.
//        var difference = currentValue - targetValue
//        if difference < 0 {
//            difference = -difference //difference * -1와 같다.
//        } //값이 마이너스가 되는 것을 방지하기 위해서
        
        let difference = abs(targetValue - currentValue) //값을 변경할 필요가 없다면 상수(let)으로 만든다.
        //상수를 선언하더라도, local 상수가 되어 showAlert 범위 내에서만 유효하다.
        var points = 100 - difference
        let title: String //상수는 초기화해버리면 값을 변경시킬 수 없으므로, 변수나 초기화하지 않은 상수를 사용한다.
        
        if difference == 0 { //여기서 서로 상호배타적이므로 title가 하나의 값으로만 초기화된다.
            title = "Perfect!"
            points += 100
        } else if difference < 5 {
            title = "You almost had it!"
            if difference == 1 {
                points += 50
            }
        } else if difference < 10 {
            title = "Pretty good!"
        } else { //만약 else를 지운다면, title은 모든 경우의 수를 만족한다 하더라도 컴파일러는 알 수 없으므로 에러가 난다.
            title = "Not even close..."
        }
        
        score += points //score = score + points와 같다.
        
        //        let message = "The value of the slider is: \(currentValue)" +
        //                      "\nThe target value is: \(targetValue)" +
        //                      "\nThe difference is: \(difference)" //문자열도 이런식으로 붙여 나갈 수 있다.
        let message = "You scored \(points) points"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert) //스위프트에서는 꼭 큰 따옴표로 문자열을 표현해야 한다.
        let action = UIAlertAction(title: "OK", style: .default) { action in //handler를 이런 식으로 줄여 쓸 수 있다.
            self.startNewRound() //클로저 밖에서는 startNewRound()라고만 써도 되지만 클로저에서는 self를 써줘야 한다.
            //어떤 이벤트에 의해 self가 nil이 될 수도 있다. 그러면 오류가 나게 되는데 클로저는 self를 써서 값을 미리 캡쳐해 둔다.
        }
        alert.addAction(action)
        present(alert, animated: true) //completion이 nil일 경우 이렇게 줄여쓸 수 있다.
        //기본적으로는 alert이 떠도 어플은 이 밑의 다른 코드를 실행한다.
        //따라서 alert 창이 뜨더라도 다른 코드의 실행을 하지 않게 하려면 클로저 등의 다른 코드가 추가되어야 한다.
    }
    
    @IBAction func sliderMoved(_ slider: UISlider) {
        currentValue = lroundf(slider.value) //Float을 받아서 Int로 반올림
//        print("The value of the slider is now \(slider.value)") //문자열 사이에 \()로 placeholder.
    }
    
    @IBAction func startNewGame() {
        score = 0
        round = 0
        startNewRound()
        
        //애니메이션 추가
        let transition = CATransition() //CATransition은 CAAnimation에서 전환효과에 사용되는 애니메이션
        transition.type = kCATransitionFade //전환 효과 타입
        transition.duration = 1 //전환 효과 지속 시간
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut) //애니메이션이 일어나는 타이밍을 설정한다.
        //kCAMediaTimingFunctionLinear : 일정한 속도로 재생
        //kCAMediaTimingFunctionEaseIn : 처음에 천천히 시작
        //kCAMediaTimingFunctionEaseOut : 마지막에 천천히 종료
        //kCAMediaTimingFunctionEaseInEaseOut : 천천히 시작하고 마지막에 다시 천천히 종료
        //https://jongryong.wordpress.com/2011/08/08/ios%EC%97%90%EC%84%9C-%EC%95%A0%EB%8B%88%EB%A9%94%EC%9D%B4%EC%85%98%EC%9D%84-%EC%82%AC%EC%9A%A9%ED%95%B4-%EB%B3%B4%EC%9E%90-core-animation/
        //http://blog.naver.com/PostView.nhn?blogId=itperson&logNo=220984805081&categoryNo=0&parentCategoryNo=0&viewDate=&currentPage=1&postListTopCurrentPage=1&from=postView
        
        view.layer.add(transition, forKey: nil)
    }
    
    func startNewRound() { //일반 메서드들은 @IBAction과 달리 실제로 호출하지 않는 이상 작동하지 않는다.
        round += 1
        targetValue = 1 + Int(arc4random_uniform(100)) //arc4random_uniform(100)은 0에서 99까지의 난수 생성
        //slider.value은 Float형이므로, 그대로 값을 사용할 경우, 사용자가 정답을 맞추기 힘들다.
        currentValue = 50
        slider.value = Float(currentValue) //slider.value이 Float형이므로 형변환해줘야 한다.
        updateLabels()
    }
    
    func updateLabels() {
        targetLabel.text = String(targetValue) //"\(targetValue)"과 같다.
        scoreLabel.text = String(score)
        roundLabel.text = String(round)
    }
}

//⌘키를 누르고 메서드를 선택하면 범위를 볼 수 있다.

//픽셀 : 디자인 시 중요.
//  - iPhone 4이전(iPhone 3Gs, iPod touch)는 1x : iOS 11을 실행하는 1x 장치는 없다. (iOS 9 이후 버전부터 지원 안 됨)
//  - iPhone 4이후는 2x : Retina
//  - +모델은 3x
// 2x, 3x는 각각 이미지 파일 이름이 각각 @2x, @3x로 끝나지만, 1x는 쓸 필요가 없다.

//Assets.xcassets에서 App icon을 설정해 줄 때에는 각 기기의 pt에 배율(x1, x2, x3)을 곱한 이미지를 넣어주면 된다.

//가로 모드일 때 status bar가 보이지 않는 것이 기본값

//변수 범위
//  - Global scope : 앱이 지속되는 동안
//  - Instance scope : 인스턴스가 해제되지 않는 동안. 오브젝트의 파라미터 등
//  - Local scope : 메스드의 아규먼트 등

//iOS 11이 되면서 오토 레이아웃에 상단 레이아웃, 하단 레이아웃에 맞춰서 하는 것이 warning이 뜬다. (네비게이션 뷰, 탭 뷰 등에 맞춰서 오토 레이아웃 제약조건) - deprecated 됨.
//대신 Safe Area라는 새로운 레이아웃 가이드를 활용해야 한다.
//기본적으로 오토레이아웃을 해도 약간의 여백이 있다. //Constrain to margins 옵션으로 조절. 기본적인 간격 해제

//Xcode 9부터 USB로 연결하지 않고 네트워크로 연결해서 디바이스로 어플리케이션을 실행할 수 있다. 근데.. 느리다..

//Certification - 배포 인증서(유료), 개발 인증서(무료).
//Provisioning Profile - 특정 디바이스에서 사용할 수 있도록 서명.
//Xcode 9부터 Xcode 내에서 디바이스 등록, 인증서 작성, 프로비저닝 프로파일 다운로드를 모두 처리할 수 있다.
