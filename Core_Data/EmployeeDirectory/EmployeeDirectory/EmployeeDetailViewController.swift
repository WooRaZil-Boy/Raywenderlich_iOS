//
//  EmployeeDetailViewController.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class EmployeeDetailViewController: UIViewController {
    //MARK: - Properties
    fileprivate lazy var dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "MM/dd/yyyy"
        
        return fmt
    }()
    
    var employee: Employee?
    
    //MARK: IBOutlets
    @IBOutlet var headShotImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var departmentLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneNumberLabel: UILabel!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var vacationDaysLabel: UILabel!
    @IBOutlet var salesCountLabel: UILabel!
    @IBOutlet var bioTextView: UITextView!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SegueEmployeeDetailToEmployeePicture",
              let controller = segue.destination as? EmployeePictureViewController else {
                return
        }
        
        controller.employee = employee
    }
}

//MARK: - Private
private extension EmployeeDetailViewController {
    func configureView() {
        guard let employee = employee else { return }
        
        title = employee.name
        
        let image = UIImage(data: employee.pictureThumbnail)
        headShotImageView.image = image
        
        nameLabel.text = employee.name
        departmentLabel.text = employee.department
        emailLabel.text = employee.email
        phoneNumberLabel.text = employee.phone
        startDateLabel.text = dateFormatter.string(from: employee.startDate)
        vacationDaysLabel.text = String(employee.vacationDays.intValue)
        bioTextView.text = employee.about
        salesCountLabel.text = salesCountForEmployeeFast(employee)
    }
}

//MARK: - Internal
extension EmployeeDetailViewController {
    func salesCountForEmployee(_ employee: Employee) -> String { //단순히 합산한 값만 알면 되는데. sale의 모든 세부 내용까지 불러오므로 비효율적.
        let fetchRequest: NSFetchRequest<Sale> = NSFetchRequest(entityName: "Sale")
        let predicate = NSPredicate(format: "employee == %@", employee)
        fetchRequest.predicate = predicate
        
        let context = employee.managedObjectContext!
        
        do {
            let results = try context.fetch(fetchRequest)
            
            return "\(results.count)"
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            
            return "0"
        }
    }
    
    func salesCountForEmployeeFast(_ employee: Employee) -> String {
        let fetchRequest: NSFetchRequest<Sale> = NSFetchRequest(entityName: "Sale")
        let predicate = NSPredicate(format: "employee == %@", employee)
        fetchRequest.predicate = predicate
        
        let context = employee.managedObjectContext!
        
        do {
            let results = try context.count(for: fetchRequest) //count로 바꿈
            
            return "\(results)"
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            
            return "0"
        }
    }
    
    func salesCountForEmployeeSimple(_ employee: Employee) -> String { //employee에 있는 sales Set을 이용
        return "\(employee.sales.count)"
    }
}

