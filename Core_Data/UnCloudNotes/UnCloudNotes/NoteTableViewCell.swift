//
//  NoteTableViewCell.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    //MARK: - Properties
    var note: Note? {
        didSet { //옵저버로 초기화
            guard let note = note else { return }
            updateNoteInfo(note: note)
        }
    }
    
    //MARK: - IBOutlets
    @IBOutlet fileprivate var noteTitle: UILabel!
    @IBOutlet fileprivate var noteCreateDate: UILabel!
}

//MARK: - Internal
extension NoteTableViewCell {
    func updateNoteInfo(note: Note) {
        noteTitle.text = note.title
        noteCreateDate.text = note.dateCreated.description
    }
}
