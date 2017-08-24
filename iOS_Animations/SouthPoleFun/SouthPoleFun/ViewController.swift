//
//  ViewController.swift
//  SouthPoleFun
//
//  Created by 근성가이 on 2017. 1. 22..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var penguin: UIImageView!
    @IBOutlet var slideButton: UIButton!
    
    var isLookingRight: Bool = true {
        didSet { //펭귄이 방향 전환 할 때마다 옵저버로 그림의 좌우와 슬라이드 버튼의 좌우를 맞게 바꿔준다.
            let xScale: CGFloat = isLookingRight ? 1 : -1
            penguin.transform = CGAffineTransform(scaleX: xScale, y: 1) //꼭 비율 축소 확대가 아니라 -1를 줘서 방향을 반대로 전환시켜(뒤집힌다) 줄 수도 있다.
            slideButton.transform = penguin.transform
        }
    }
    
    var penguinY: CGFloat = 0.0
    
    var walkSize: CGSize = CGSize.zero
    var slideSize: CGSize = CGSize.zero
    
    let animationDuration = 1.0
    
    var walkFrames = [
        UIImage(named: "walk01.png")!,
        UIImage(named: "walk02.png")!,
        UIImage(named: "walk03.png")!,
        UIImage(named: "walk04.png")!
    ]
    
    var slideFrames = [
        UIImage(named: "slide01.png")!,
        UIImage(named: "slide02.png")!,
        UIImage(named: "slide01.png")!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //grab the sizes of the different sequences
        walkSize = walkFrames[0].size //이미지 픽셀의 크기를 가져온다.
        print(walkSize)
        slideSize = slideFrames[0].size
        
        //setup the animation
        penguinY = penguin.frame.origin.y
        
        loadWalkAnimation()
    }
    
    func loadWalkAnimation() {
        penguin.animationImages = walkFrames //연속된 이미지들
        penguin.animationDuration = animationDuration / 3 //지속 시간
        penguin.animationRepeatCount = 3 //반복 //3번 짧게 걷는다.
    }
    
    func loadSlideAnimation() {
        penguin.animationImages = slideFrames
        penguin.animationDuration = animationDuration
        penguin.animationRepeatCount = 1
    }
    
    @IBAction func actionLeft(_ sender: AnyObject) {
        isLookingRight = false
        penguin.startAnimating() //애니메이션 실행
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.penguin.center.x -= self.walkSize.width //이미지 픽셀의 너비 만큼 애니메이션으로 이동
        }, completion: nil)
    }
    
    @IBAction func actionRight(_ sender: AnyObject) {
        isLookingRight = true
        penguin.startAnimating()
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.penguin.center.x += self.walkSize.width
        }, completion: nil)
    }
    
    @IBAction func actionSlide(_ sender: AnyObject) {
        loadSlideAnimation()
        
        penguin.frame = CGRect(x: penguin.frame.origin.x, y: penguinY + (walkSize.height - slideSize.height), width: slideSize.width, height: slideSize.height) //프레임을 맞춰준다. //약간 밑으로 이동시켜 걷는 프레임과 맞춰준다.
        penguin.startAnimating()
        
        UIView.animate(withDuration: animationDuration - 0.02, delay: 0.0, options: .curveEaseOut, animations: { //0.02초 정도 빼는 이유는 딱 맞춰서 애니메이션을 지정하면 겹치면서 오류가 날 수도 있기 때문에 조금 빼준다.
            self.penguin.center.x += self.isLookingRight ? self.slideSize.width : -self.slideSize.width //바라보는 위치 따라서 방향이 바뀐다.
        }, completion: { _ in
            self.penguin.frame = CGRect(x: self.penguin.frame.origin.x, y: self.penguinY, width: self.walkSize.width, height: self.walkSize.height) //원래 대로 맞춰준다.
            self.loadWalkAnimation() //걷는 애니메이션으로 다시 지정
        })
    }
}

