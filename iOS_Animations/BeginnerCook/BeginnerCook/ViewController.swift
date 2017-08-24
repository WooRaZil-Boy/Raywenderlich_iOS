//
//  ViewController.swift
//  BeginnerCook
//
//  Created by 근성가이 on 2017. 1. 14..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

let herbs = HerbModel.all()

class ViewController: UIViewController, UIViewControllerTransitioningDelegate { //애니메이션 델리게이트 설정
    
    //MARK: - Properties
    @IBOutlet var listView: UIScrollView!
    @IBOutlet var bgImage: UIImageView!
    var selectedImage: UIImageView?
    
    let transition = PopAnimator() //애니메이션 프로퍼티 
}

//MARK - View Life Cycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transition.dismissCompletion = { 
            self.selectedImage?.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if listView.subviews.count < herbs.count {
            listView.viewWithTag(0)?.tag = 1000 //prevent confusion when looking up images
            setupList()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) { //기기의 방향을 처리 //UIViewControllerTransitionCoordinator이므로 toView, fromView등을 가져 올 수 있다.
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.bgImage.alpha = size.width > size.height ? 0.25 : 0.55 //가독성을 위해
            self.positionListItems() //가로 세로 전환 시, 이미지 뷰의 위치를 다시 계산
        }, completion: nil)
    }
}

//MARK: - View setup
extension ViewController {
    //add all images to the list
    func setupList() {
        for i in herbs.indices { //CollectionType은 indices라는 값을 가지는데, 이 값은 유효한 값의 범위를 가진다. 이를 사용하면 안전하게 배열에서 값을 얻을 수 있습니다. -> out of index를 방지?
            
            //create image view
            let imageView  = UIImageView(image: UIImage(named: herbs[i].image))
            imageView.tag = i
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.layer.cornerRadius = 20.0
            imageView.layer.masksToBounds = true
            listView.addSubview(imageView)
            
            //attach tap detector
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapImageView)))
        }
        
        listView.backgroundColor = UIColor.clear
        positionListItems()
    }
    
    //position all images inside the list
    func positionListItems() {
        let listHeight = listView.frame.height
        let itemHeight: CGFloat = listHeight * 1.33
        let aspectRatio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        let itemWidth: CGFloat = itemHeight / aspectRatio
        
        let horizontalPadding: CGFloat = 10.0
        
        for i in herbs.indices {
            let imageView = listView.viewWithTag(i) as! UIImageView
            imageView.frame = CGRect(
                x: CGFloat(i) * itemWidth + CGFloat(i+1) * horizontalPadding, y: 0.0,
                width: itemWidth, height: itemHeight)
        }
        
        listView.contentSize = CGSize(
            width: CGFloat(herbs.count) * (itemWidth + horizontalPadding) + horizontalPadding,
            height: 0)
    }
}

//MARK: - Actions
extension ViewController {
    func didTapImageView(_ tap: UITapGestureRecognizer) {
        selectedImage = tap.view as? UIImageView
        
        let index = tap.view!.tag
        let selectedHerb = herbs[index]
        
        //present details view controller
        let herbDetails = storyboard!.instantiateViewController(withIdentifier: "HerbDetailsViewController") as! HerbDetailsViewController
        herbDetails.herb = selectedHerb
        herbDetails.transitioningDelegate = self //애니메이션 델리게이트를 지정해 준다.
        present(herbDetails, animated: true, completion: nil)
    }
}

extension ViewController {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? { //UIKit은 animationController (forPresented : presenting : source :)를 호출하여 UIViewControllerAnimatedTransitioning이 반환되는지 확인한다. 이 메서드가 nil을 반환하면 UIKit은 기본 제공 전환을 사용한다. UIKit가 대신 UIViewControllerAnimatedTransitioning 객체를 받으면 UIKit은 해당 객체를 전환을위한 애니메이션 컨트롤러로 사용한다.
        transition.originFrame = selectedImage!.superview!.convert(selectedImage!.frame, to: nil) //좌표공간 변환 //애니메이션이 시작될 프레임을 설정해 준다. //이 값을 따로 설정해 주지 않으면, 기본 위치인 0,0이 디폴트로 들어가기 때문에 항상 왼쪽 위에서 부터 시작된다.
        transition.presenting = true
        selectedImage!.isHidden = true
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? { //animationController (forPresented : presenting : source :)의 작동과 거의 비슷하다. 뷰 컨트롤러가 종료 될 때, 애니메이션을 지정하고 nil이 반환되면 기본 전환을 사용한다.
        transition.presenting = false
            
        return transition
    }
}
