//
//  CreateNoteViewController.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class CreateNoteViewController: UIViewController, UsesCoreDataObjects {
    //MARK: - Properties
    var managedObjectContext: NSManagedObjectContext?
    lazy var note: Note? = {
        guard let context = self.managedObjectContext else { return nil }
        
        return Note(context: context)
    }()
    
    //MARK: - IBOutlets
    @IBOutlet fileprivate var titleField: UITextField!
    @IBOutlet fileprivate var bodyField: UITextView!
    @IBOutlet private var attachPhotoButton: UIButton!
    @IBOutlet private var attachedPhoto: UIImageView!
    
    //MARK: - View Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let image = note?.image else {
            titleField.becomeFirstResponder()
            return
        }
        
        attachedPhoto.image = image
        view.endEditing(true)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController = segue.destination as? NoteDisplayable else { return }
        
        nextViewController.note = note
    }
}

//MARK: - IBActions
extension CreateNoteViewController {
    @IBAction func saveNote() {
        guard let note = note, let managedObjectContext = managedObjectContext else {
            return
        }
        
        note.title = titleField.text ?? ""
        note.body = bodyField.text ?? ""
        
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            print("Error saving \(error)", terminator: "")
        }
        
        performSegue(withIdentifier: "unwindToNotesList", sender: self)
    }
}

//MARK: - UITextFieldDelegate
extension CreateNoteViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveNote()
        textField.resignFirstResponder()
        
        return false
    }
}

//MARK: - UITextViewDelegate
extension CreateNoteViewController: UITextViewDelegate {
    
}
