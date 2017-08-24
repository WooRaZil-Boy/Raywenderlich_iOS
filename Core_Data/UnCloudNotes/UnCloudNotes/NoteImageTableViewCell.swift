//
//  NoteImageTableViewCell.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit

class NoteImageTableViewCell: NoteTableViewCell {
    //MARK: - IBOutlets
    @IBOutlet fileprivate var noteImage: UIImageView!
}

// MARK: - Internal
extension NoteImageTableViewCell {
    override func updateNoteInfo(note: Note) {
        super.updateNoteInfo(note: note)
        
        noteImage.image = note.image
    }
}
