//
//  ViewController.swift
//  BullsEye
//
//  Created by 근성가이 on 2017. 12. 20..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

//앱은 사용자가 종료해야 종료가 된다. 대기 상태로 있으면서 이벤트를 기다리고, 이벤트가 발생하면 처리한 후 다시 대기 모드로 들어간다.
//Warning이 프로그램 실행에 영향을 끼치지는 않지만 왠만하면 warning도 제거해라.
class ViewController: UIViewController {
    var currentValue: Int = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showAlert() { //IBAction으로 스토리보드와 연결시켜 준다.
        let message = "The value of the slider is: \(currentValue)"
        let alert = UIAlertController(title: "Hello, World", message: message, preferredStyle: .alert) //스위프트에서는 꼭 큰 따옴표로 문자열을 표현해야 한다.
        let action = UIAlertAction(title: "OK", style: .default) //handler가 nil일 경우 이렇게 줄여 쓸 수 있다.
        alert.addAction(action)
        present(alert, animated: true) //completion이 nil일 경우 이렇게 줄여쓸 수 있다.
    }
    
    @IBAction func sliderMoved(_ slider: UISlider) {
        currentValue = lroundf(slider.value) //Float을 받아서 Int로 반올림
//        print("The value of the slider is now \(slider.value)") //문자열 사이에 \()로 placeholder.
    }
}

//⌘키를 누르고 메서드를 선택하면 범위를 볼 수 있다.

//픽셀 : 디자인 시 중요.
//  - iPhone 4이전(iPhone 3Gs, iPod touch)는 1x
//  - iPhone 4이후는 2x
//  - +모델은 3x

//가로 모드일 때 status bar가 보이지 않는 것이 기본값

