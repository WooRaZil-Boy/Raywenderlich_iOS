//
//  JournalListViewController.swift
//  SurfJournal
//
//  Created by 근성가이 on 2017. 1. 5..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class JournalListViewController: UITableViewController {
    //MARK: - Properties
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<JournalEntry> = NSFetchedResultsController()
    
    //MARK: - IBOutlets
    @IBOutlet weak var exportButton: UIBarButtonItem!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //1
        if segue.identifier == "SegueListToDetail" {
            
            //2
            guard let navigationController = segue.destination as? UINavigationController,
                let detailViewController = navigationController.topViewController as? JournalEntryViewController,
                let indexPath = tableView.indexPathForSelectedRow else {
                    fatalError("Application storyboard mis-configuration")
            }
            
            //3
            let surfJournalEntry = fetchedResultsController.object(at: indexPath)
            
            //4
            
            //1
            let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType) //새로운 컨텍스트
            childContext.parent = coreDataStack.mainContext //부모를 설정
            
            //2
            let childEntry = childContext.object(with: surfJournalEntry.objectID) as? JournalEntry //자식 컨텍스토 사용
            
            //3
            detailViewController.journalEntry = childEntry //자식 엔트리 사용
            detailViewController.context = childContext //컨텍스트를 전달하지 않으면 약한 참조로 제거될 수 있다.
            detailViewController.delegate = self
        } else if segue.identifier == "SegueListToDetailAdd" {
            guard let navigationController = segue.destination as? UINavigationController,
                let detailViewController = navigationController.topViewController as? JournalEntryViewController else {
                    fatalError("Application storyboard mis-configuration")
            }
            
            let newJournalEntry = JournalEntry(context: coreDataStack.mainContext)
            
            detailViewController.journalEntry = newJournalEntry
            detailViewController.context = newJournalEntry.managedObjectContext
            detailViewController.delegate = self
        }
    }
}

//MARK: - IBActions
extension JournalListViewController {
    @IBAction func exportButtonTapped(_ sender: UIBarButtonItem) {
        exportCSVFile()
    }
}

//MARK: - Private
private extension JournalListViewController {
    func configureView() {
        fetchedResultsController = journalListFetchedResultsController()
    }
    
    func exportCSVFile() { //메인 큐에서 작업하면 내보내기 작업을 하는 동안에는 UI를 사용할 수 없다. 다른 큐를 사용하여 문제 해결
        navigationItem.leftBarButtonItem = activityIndicatorBarButtonItem()
        
        //1
        coreDataStack.storeContainer.performBackgroundTask { context in //다른 큐를 만들어 백그라운드 에서 작업 //PrivateQueueConcurrencyType로 큐를 분리해도 된다
            var results: [JournalEntry] = []
            
            do {
                results = try context.fetch(self.surfJournalFetchRequest())
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
            }
            
            //2
            let exportFilePath = NSTemporaryDirectory() + "export.csv" //NSTemporaryDirectory가 반환하는 경로는 임시 파일 저장을위한 고유 한 디렉터리 //쉽게 다시 생성할 수 있고, 백업 할 필요가 없는 파일에 적합
            let exportFileURL = URL(fileURLWithPath: exportFilePath)
            FileManager.default.createFile(atPath: exportFilePath, contents: Data(), attributes: nil) //지정한 경로에 파일이 있는 경우에는 삭제 후 생성
            
            let fileHandle: FileHandle?
            do {
                fileHandle = try FileHandle(forWritingTo: exportFileURL)
            } catch let error as NSError {
                print("ERROR: \(error.localizedDescription)")
                fileHandle = nil
            }
            
            //3
            if let fileHandle = fileHandle {
                //4
                for journalEntry in results {
                    fileHandle.seekToEndOfFile()
                    
                    guard let csvData = journalEntry
                        .csv()
                        .data(using: .utf8, allowLossyConversion: false) else {
                            continue
                    }
                    
                    fileHandle.write(csvData)
                }
                
                //5
                fileHandle.closeFile()
                
                print("Export Path: \(exportFilePath)")
                //6
                DispatchQueue.main.async { //메인 큐에서 UI업데이트. //UI에 대한 변경사항은 항상 메인 큐에서 작업되어야 한다.
                    self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
                    self.showExportFinishedAlertView(exportFilePath)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.navigationItem.leftBarButtonItem = self.exportBarButtonItem()
                }
            }
        } //7 Closing brace for performBackgroundTask
    }
    
    //MARK: - Export
    func activityIndicatorBarButtonItem() -> UIBarButtonItem {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        let barButtonItem = UIBarButtonItem(customView: activityIndicator)
        activityIndicator.startAnimating()
        
        return barButtonItem
    }
    
    func exportBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportButtonTapped(_:)))
    }
    
    func showExportFinishedAlertView(_ exportPath: String) {
        let message = "The exported CSV file can be found at \(exportPath)"
        let alertController = UIAlertController(title: "Export Finished", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)
        
        present(alertController, animated: true)
    }
}

//MARK: - NSFetchedResultsController
private extension JournalListViewController {
    func journalListFetchedResultsController() -> NSFetchedResultsController<JournalEntry> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: surfJournalFetchRequest(),
                                                                 managedObjectContext: coreDataStack.mainContext,
                                                                 sectionNameKeyPath: nil,
                                                                 cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func surfJournalFetchRequest() -> NSFetchRequest<JournalEntry> {
        let fetchRequest = NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        return fetchRequest
    }
}

// MARK: NSFetchedResultsControllerDelegate
extension JournalListViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource
extension JournalListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SurfEntryTableViewCell
        configureCell(cell, indexPath: indexPath)
        
        return cell
    }
    
    private func configureCell(_ cell: SurfEntryTableViewCell, indexPath:IndexPath) {
        let surfJournalEntry = fetchedResultsController.object(at: indexPath)
        cell.dateLabel.text = surfJournalEntry.stringForDate()
        
        guard let rating = surfJournalEntry.rating?.int32Value else { return }
        
        switch rating {
        case 1:
            cell.starOneFilledImageView.isHidden = false
            cell.starTwoFilledImageView.isHidden = true
            cell.starThreeFilledImageView.isHidden = true
            cell.starFourFilledImageView.isHidden = true
            cell.starFiveFilledImageView.isHidden = true
        case 2:
            cell.starOneFilledImageView.isHidden = false
            cell.starTwoFilledImageView.isHidden = false
            cell.starThreeFilledImageView.isHidden = true
            cell.starFourFilledImageView.isHidden = true
            cell.starFiveFilledImageView.isHidden = true
        case 3:
            cell.starOneFilledImageView.isHidden = false
            cell.starTwoFilledImageView.isHidden = false
            cell.starThreeFilledImageView.isHidden = false
            cell.starFourFilledImageView.isHidden = true
            cell.starFiveFilledImageView.isHidden = true
        case 4:
            cell.starOneFilledImageView.isHidden = false
            cell.starTwoFilledImageView.isHidden = false
            cell.starThreeFilledImageView.isHidden = false
            cell.starFourFilledImageView.isHidden = false
            cell.starFiveFilledImageView.isHidden = true
        case 5:
            cell.starOneFilledImageView.isHidden = false
            cell.starTwoFilledImageView.isHidden = false
            cell.starThreeFilledImageView.isHidden = false
            cell.starFourFilledImageView.isHidden = false
            cell.starFiveFilledImageView.isHidden = false
        default :
            cell.starOneFilledImageView.isHidden = true
            cell.starTwoFilledImageView.isHidden = true
            cell.starThreeFilledImageView.isHidden = true
            cell.starFourFilledImageView.isHidden = true
            cell.starFiveFilledImageView.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard case(.delete) = editingStyle else { return }
        
        let surfJournalEntry = fetchedResultsController.object(at: indexPath)
        coreDataStack.mainContext.delete(surfJournalEntry)
        coreDataStack.saveContext()
    }
}

//MARK: - JournalEntryDelegate
extension JournalListViewController: JournalEntryDelegate {
    func didFinish(viewController: JournalEntryViewController, didSave: Bool) {
        
        //1
        guard didSave,
            let context = viewController.context,
            context.hasChanges else {
                dismiss(animated: true)
                return
        }
        
        //2
        context.perform { //주 컨텍스트
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            //3
            self.coreDataStack.saveContext()
        }
        
        //4
        dismiss(animated: true)
    }
}
