//
//  ViewController.swift
//  BullsEye
//
//  Created by 근성가이 on 2017. 12. 20..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

//앱은 사용자가 종료해야 종료가 된다. 대기 상태로 있으면서 이벤트를 기다리고, 이벤트가 발생하면 처리한 후 다시 대기 모드로 들어간다.
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showAlert() { //IBAction으로 스토리보드와 연결시켜 준다.
        let alert = UIAlertController(title: "Hello, World", message: "This is my first app!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Awesome", style: .default) //handler가 nil일 경우 이렇게 줄여 쓸 수 있다.
        alert.addAction(action)
        present(alert, animated: true) //completion이 nil일 경우 이렇게 줄여쓸 수 있다.
    }
} //⌘키를 누르고 메서드를 선택하면 범위를 볼 수 있다.

