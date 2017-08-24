//
//  ViewController.swift
//  BowTies
//
//  Created by 근성가이 on 2016. 12. 20..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var timesWornLabel: UILabel!
    @IBOutlet weak var lastWornLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    var managedContext: NSManagedObjectContext!
    var currentBowtie: Bowtie!
}

//MARK: - View Life Cycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insertSampleData()
        
        let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        let firstTitle = segmentedControl.titleForSegment(at: 0)!
        request.predicate = NSPredicate(format: "searchKey == %@", firstTitle) //필터링
        
        do {
            let results = try managedContext.fetch(request)
            currentBowtie = results.first
            
            populate(bowtie: results.first!)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

//MARK: - IBActions
extension ViewController {
    @IBAction func segmentedControl(_ sender: AnyObject) {
        guard let control = sender as? UISegmentedControl else {
            return
        }
        
        let selectedValue = control.titleForSegment(at: control.selectedSegmentIndex)
        let request = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        request.predicate = NSPredicate(format: "searchKey == %@", selectedValue!) //조건. 하나만 불러오게 된다.
        
        do {
            let results = try managedContext.fetch(request)
            currentBowtie = results.first
            
            populate(bowtie: currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func wear(_ sender: AnyObject) {
        let times = currentBowtie.timesWorn
        currentBowtie.timesWorn = times + 1
        
        currentBowtie.lastWorn = NSDate()
        
        do {
            try managedContext.save()
            populate(bowtie: currentBowtie)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func rate(_ sender: AnyObject) {
        let alert = UIAlertController(title: "New Rating", message: "Rate this bow tie", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .decimalPad
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first else {
                return
            }
            
            self.update(rating: textField.text)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
}

//MARK: - CoreData
extension ViewController {
    func insertSampleData() {
        let fetch = NSFetchRequest<Bowtie>(entityName: "Bowtie")
        fetch.predicate = NSPredicate(format: "searchKey != nil")
        
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            //SampleData.plist data already in Core Data
            return
        }
        
        let path = Bundle.main.path(forResource: "SampleData", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Bowtie", in: managedContext)!
            let bowtie = Bowtie(entity: entity, insertInto: managedContext)
            let btDict = dict as! [String: AnyObject]
            
            bowtie.name = btDict["name"] as? String
            bowtie.searchKey = btDict["searchKey"] as? String
            bowtie.rating = btDict["rating"] as! Double
            let colorDict = btDict["tintColor"] as! [String: AnyObject]
            bowtie.tintColor = UIColor.color(dict: colorDict)
            
            let imageName = btDict["imageName"] as? String
            let image = UIImage(named: imageName!)
            let photoData = UIImagePNGRepresentation(image!)!
            bowtie.photoData = NSData(data: photoData)
            
            bowtie.lastWorn = btDict["lastWorn"] as? NSDate
            let timesNumber = btDict["timesWorn"] as! NSNumber
            bowtie.timesWorn = timesNumber.int32Value
            bowtie.isFavorite = btDict["isFavorite"] as! Bool
        }
        
        try! managedContext.save()
    }
    
    func populate(bowtie: Bowtie) {
        guard let imageData = bowtie.photoData as? Data, let lastWorn = bowtie.lastWorn as? Date, let tintColor = bowtie.tintColor as? UIColor else {
            return
        }
        
        imageView.image = UIImage(data: imageData)
        nameLabel.text = bowtie.name
        ratingLabel.text = "Rating: \(bowtie.rating)/5"
        
        timesWornLabel.text = "# times worn: \(bowtie.timesWorn)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        lastWornLabel.text = "Last worn: " + dateFormatter.string(from: lastWorn)
        
        favoriteLabel.isHidden = !bowtie.isFavorite
        view.tintColor = tintColor
    }
    
    func update(rating: String?) {
        guard let ratingString = rating, let rating = Double(ratingString) else {
            return
        }
        
        do {
            currentBowtie.rating = rating
            try managedContext.save()
            
            populate(bowtie: currentBowtie)
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && (error.code == NSValidationNumberTooLargeError || error.code == NSValidationNumberTooSmallError) { //설정된 범위 이외의 값 //CoreDataErrors.h에 설정
                rate(currentBowtie)
            } else {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
    }
}

//MARK: - UIColor+Extension
private extension UIColor {
    static func color(dict: [String: AnyObject]) -> UIColor? {
        guard let red = dict["red"] as? NSNumber, let green = dict["green"] as? NSNumber, let blue = dict["blue"] as? NSNumber else {
                return nil
        }
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1)
    }
}
