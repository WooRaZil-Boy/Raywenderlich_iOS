//
//  EmployeeListViewController.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class EmployeeListViewController: UITableViewController {
    //MARK: - Properties
    var coreDataStack: CoreDataStack!
    var fetchedResultController: NSFetchedResultsController<Employee> = NSFetchedResultsController() //테이블 뷰 컨트롤러와 연계된 컨트롤러
    var department: String?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SegueEmployeeListToDetail",
              let indexPath = tableView.indexPathForSelectedRow,
              let controller = segue.destination as? EmployeeDetailViewController else {
                return
        }
        
        let selectedEmployee = fetchedResultController.object(at: indexPath)
        controller.employee = selectedEmployee
    }
}

//MARK: - Private
private extension EmployeeListViewController {
    func configureView() {
        fetchedResultController = employeesFetchedResultControllerFor(department)
    }
}

//MARK: - NSFetchedResultsController
extension EmployeeListViewController {
    func employeesFetchedResultControllerFor(_ department: String?) -> NSFetchedResultsController<Employee> {
        fetchedResultController = NSFetchedResultsController(fetchRequest: employeeFetchRequest(department),
                                                             managedObjectContext: coreDataStack.mainContext,
                                                             sectionNameKeyPath: nil,
                                                             cacheName: nil)
        
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
            return fetchedResultController
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    func employeeFetchRequest(_ department: String?) -> NSFetchRequest<Employee> {
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        fetchRequest.fetchBatchSize = 10 //보통 화면에 나타나는 항목 수의 두 배 정도로 설정하는 것이 적당.
        let sortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard let department = department else {
            return fetchRequest
        }
        
        fetchRequest.predicate = NSPredicate(format: "department == %@", department)
        
        return fetchRequest
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension EmployeeListViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension EmployeeListViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultController.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultController.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "EmployeeCellReuseIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                 for: indexPath) as! EmployeeTableViewCell
        
        let employee = fetchedResultController.object(at: indexPath)
        
        cell.nameLabel.text = employee.name
        cell.departmentLabel.text = employee.department
        cell.emailLabel.text = employee.email
        cell.phoneNumberLabel.text = employee.phone
        cell.pictureImageView.image = UIImage(data: employee.pictureThumbnail)
        
        return cell
    }
}
