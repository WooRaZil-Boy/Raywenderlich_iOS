//
//  AttachPhotoViewController.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class AttachPhotoViewController: UIViewController {
    //MARK: - Properties
    var note : Note?
    lazy var imagePicker : UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.addChildViewController(picker)
        
        return picker
    }()
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(imagePicker)
        view.addSubview(imagePicker.view)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imagePicker.view.frame = view.bounds
    }
}

//MARK: - UIImagePickerControllerDelegate
extension AttachPhotoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let note = note, let context = note.managedObjectContext else {
            return
        }
        
        let attachment = ImageAttachment(context: context)
        attachment.dateCreated = Date()
        attachment.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        attachment.note = note
        
        _ = navigationController?.popViewController(animated: true) //네비게이션 컨트롤러 최상단 컨트롤러 해제(이미지 뷰)
    }
}

//MARK: - UINavigationControllerDelegate
extension AttachPhotoViewController: UINavigationControllerDelegate {
    
}

//MARK: - NoteDisplayable
extension AttachPhotoViewController: NoteDisplayable {
    
}

