//
//  JournalEntryViewController.swift
//  SurfJournal
//
//  Created by 근성가이 on 2017. 1. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

//MARK: - JournalEntryDelegate
protocol JournalEntryDelegate {
    func didFinish(viewController: JournalEntryViewController, didSave: Bool)
}

class JournalEntryViewController: UITableViewController {
    //MARK: - Properties
    var journalEntry: JournalEntry?
    var context: NSManagedObjectContext!
    var delegate:JournalEntryDelegate?
    
    //MARK: - IBOutlets
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var periodTextField: UITextField!
    @IBOutlet weak var windTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var ratingSegmentedControl: UISegmentedControl!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
}

// MARK: Private
private extension JournalEntryViewController {
    func configureView() {
        guard let journalEntry = journalEntry else { return }
        
        title = journalEntry.stringForDate()
        
        heightTextField.text = journalEntry.height
        periodTextField.text = journalEntry.period
        windTextField.text = journalEntry.wind
        locationTextField.text = journalEntry.location
        
        guard let rating = journalEntry.rating else { return }
        
        ratingSegmentedControl.selectedSegmentIndex = rating.intValue - 1
    }
    
    func updateJournalEntry() {
        guard let entry = journalEntry else { return }
        
        entry.date = Date()
        entry.height = heightTextField.text
        entry.period = periodTextField.text
        entry.wind = windTextField.text
        entry.location = locationTextField.text
        entry.rating = NSNumber(value:ratingSegmentedControl.selectedSegmentIndex + 1)
    }
}

// MARK: IBActions
extension JournalEntryViewController {
    @IBAction func cancelButtonWasTapped(_ sender: UIBarButtonItem) {
        delegate?.didFinish(viewController: self, didSave: false)
    }
    
    @IBAction func saveButtonWasTapped(_ sender: UIBarButtonItem) {
        updateJournalEntry()
        delegate?.didFinish(viewController: self, didSave: true)
    }
}
