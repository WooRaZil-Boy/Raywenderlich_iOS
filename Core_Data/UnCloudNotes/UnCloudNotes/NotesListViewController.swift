//
//  NotesListViewController.swift
//  UnCloudNotes
//
//  Created by 근성가이 on 2017. 1. 3..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UITableViewController {
    //MARK: - Properties
    fileprivate lazy var stack: CoreDataStack = {
       let manager = DataMigrationManager(modelNamed: "UnCloudNotesDataModel", enableMigrations: true) //한 번만 초기화?
        
        return manager.stack
    }()
    fileprivate lazy var notes: NSFetchedResultsController<Note> = {
        let context = self.stack.managedContext
        let request = Note.fetchRequest() as! NSFetchRequest<Note>
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.dateCreated), ascending: false)]
        
        let notes = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        notes.delegate = self
        return notes
    }()
    
    //MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        do {
            try notes.performFetch()
        } catch {
            print("Error: \(error)")
        }
        
        tableView.reloadData()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
            let viewController = navController.topViewController as? UsesCoreDataObjects {
            viewController.managedObjectContext = stack.savingContext
        }
        
        if let detailView = segue.destination as? NoteDisplayable,
            let selectedIndex = tableView.indexPathForSelectedRow {
            detailView.note = notes.object(at: selectedIndex)
        }
    }
}

//MARK: - IBActions
extension NotesListViewController {
    @IBAction func unwindToNotesList(_ segue: UIStoryboardSegue) {
        print("Unwinding to Notes List")
        
        stack.saveContext()
    }
}

//MARK: - UITableViewDataSource
extension NotesListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let objects = notes.fetchedObjects
        return objects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes.object(at: indexPath)
        let cell: NoteTableViewCell
        
        if note.image == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "NoteCellWithImage", for: indexPath) as! NoteImageTableViewCell
        }
        
        cell.note = note
        
        return cell
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension NotesListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        let wrapIndexPath: (IndexPath?) -> [IndexPath] = { $0.map { [$0] } ?? [] }
        
        switch type {
        case .insert:
            tableView.insertRows(at: wrapIndexPath(newIndexPath), with: .automatic)
        case .delete:
            tableView.deleteRows(at: wrapIndexPath(indexPath), with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}

