//
//  ViewController.swift
//  ImageGallery
//
//  Created by 근성가이 on 2017. 1. 21..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController {
    let images = [
        ImageViewCard(imageNamed: "Hurricane_Katia.jpg", title: "Hurricane Katia"),
        ImageViewCard(imageNamed: "Hurricane_Douglas.jpg", title: "Hurricane Douglas"),
        ImageViewCard(imageNamed: "Hurricane_Norbert.jpg", title: "Hurricane Norbert"),
        ImageViewCard(imageNamed: "Hurricane_Irene.jpg", title: "Hurricane Irene")
    ]
    
    var isGalleryOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "info", style: .done, target: self, action: #selector(info))
    }
    
    func info() {
        let alertController = UIAlertController(title: "Info", message: "Public Domain images by NASA", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for image in images {
            image.layer.anchorPoint.y = 0.0 //앵커포인트는 프레임을 정의하기 전에 해야 //이미지가 중앙이 아닌 (0.5, 0) -> 중간 최상단을 중심으로 회전한다.
            image.frame = view.bounds
            image.didSelect = selectImage
            view.addSubview(image)
        }
        
        navigationItem.title = images.last?.title
        
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 250.0
        view.layer.sublayerTransform = perspective //모든 하위레이어의 원근을 일괄조정한다.
    }
    
    @IBAction func toggleGallery(_ sender: AnyObject) {
        if isGalleryOpen {
            for subview in view.subviews {
                guard let image = subview as? ImageViewCard else {
                    continue
                }
                
                let animation = CABasicAnimation(keyPath: "transform")
                animation.fromValue = NSValue(caTransform3D: image.layer.transform)
                animation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
                animation.duration = 0.33
                
                image.layer.add(animation, forKey: nil)
                image.layer.transform = CATransform3DIdentity
                
            }
            
            isGalleryOpen = false
            return
        }

        var imageYOffset: CGFloat = 50.0 //모든 이미지를 제자리에서 회전시키지 않고 단순히 "팬"애니메이션을 생성하기 위해 움직이면 imageYOffset을 사용해 각 이미지의 오프셋을 설정한다.
        for subview in view.subviews {
            guard let image = subview as? ImageViewCard else {
                continue
            }
            
            var imageTransform = CATransform3DIdentity
            imageTransform = CATransform3DTranslate(imageTransform, 0.0, imageYOffset, 0.0) //이동 //y축으로 50만큼
            imageTransform = CATransform3DScale(imageTransform, 0.95, 0.6, 1.0) //스케일 축소&확대 //x축 0.95 y축 0.6, z축 1 크기 만큼 축소.
            imageTransform = CATransform3DRotate(imageTransform, CGFloat(M_PI_4/2), -1.0, 0.0, 0.0) //회전 //22.5도 180/4/2
            
            let animation = CABasicAnimation(keyPath: "transform")
            animation.fromValue = NSValue(caTransform3D: image.layer.transform) //기본 값
            animation.toValue = NSValue(caTransform3D: imageTransform) //설정한 값
            animation.duration = 0.33
            image.layer.add(animation, forKey: nil)
            
            image.layer.transform = imageTransform
            imageYOffset += view.frame.height / CGFloat(images.count) //y축으로 계속 조금씩 이동해 모든 이미지들이 다 보이도록 한다.
        }
        
        isGalleryOpen = true
    }
}

extension ViewController {
    func selectImage(selectedImage: ImageViewCard) { //이미지 선택 액션
        for subview in view.subviews {
            guard let image = subview as? ImageViewCard else {
                continue
            }
            
            if image === selectedImage {
                //selected image
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseIn, animations: {
                    image.layer.transform = CATransform3DIdentity
                }, completion: { _ in
                    self.view.bringSubview(toFront: image)
                })
            } else {
                //any other image
                UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseIn, animations: {
                    image.alpha = 0.0
                }, completion: { _ in
                    image.alpha = 1.0
                    image.layer.transform = CATransform3DIdentity
                })
            }
        }
        self.navigationItem.title = selectedImage.title
        isGalleryOpen = false
    }
}

