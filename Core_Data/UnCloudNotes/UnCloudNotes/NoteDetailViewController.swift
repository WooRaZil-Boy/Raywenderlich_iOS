//
//  NoteDetailViewController.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

protocol NoteDisplayable: class {
    var note: Note? { get set }
}

class NoteDetailViewController: UIViewController, NoteDisplayable {
    //MARK: - Properties
    var note: Note? {
        didSet {
            updateNoteInfo()
        }
    }
    
    //MARK: - IBOutlets
    @IBOutlet fileprivate var titleField: UILabel!
    @IBOutlet fileprivate var bodyField: UITextView!
    
    //MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNoteInfo()
    }
}

//MARK: - Internal
extension NoteDetailViewController {
    func updateNoteInfo() {
        guard isViewLoaded, let note = note else {
                return
        }
        
        titleField.text = note.title
        bodyField.text = note.body
    }
}
