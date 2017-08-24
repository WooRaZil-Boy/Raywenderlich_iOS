//
//  EmployeePictureViewController.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class EmployeePictureViewController: UIViewController {
    //MARK: - Properties
    var employee: Employee?
    
    //MARK: - IBOutlets
    @IBOutlet var employeePictureImageView: UIImageView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
}

//MARK: - IBActions
extension EmployeePictureViewController {
    @IBAction func userTappedPicture(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
}

//MARK: - Private
private extension EmployeePictureViewController {
    func configureView() {
        guard let employee = employee else { return }
        
        employeePictureImageView.image = UIImage(data: employee.picture.picture) //relationship의 picture
    }
}

