//
//  HerbDetailsViewController.swift
//  BeginnerCook
//
//  Created by 근성가이 on 2017. 1. 14..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class HerbDetailsViewController: UIViewController, UIViewControllerTransitioningDelegate {
    //MARK: - Propertiese
    @IBOutlet var containerView: UIView!
    
    @IBOutlet var bgImage: UIImageView!
    @IBOutlet var titleView: UILabel!
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var licenseButton: UIButton!
    @IBOutlet var authorButton: UIButton!
    
    var herb: HerbModel!
}

//MARK: - View Life Cycle
extension HerbDetailsViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bgImage.image = UIImage(named: herb.image)
        titleView.text = herb.name
        descriptionView.text = herb.description
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(actionClose(_:))))
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

//MARK: - Gesture
extension HerbDetailsViewController {
    func actionClose(_ tap: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

//MARK: button actions
extension HerbDetailsViewController {
    @IBAction func actionLicense(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: herb!.license)!)
    }
    
    @IBAction func actionAuthor(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: herb!.credit)!)
    }
}
