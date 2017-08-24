//
//  AppDelegate.swift
//  EmployeeDirectory
//
//  Created by 근성가이 on 2017. 1. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: - Properties
    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "EmployeeDirectory")
    
    let amountToImport = 50 //가져올 개수 조절할 수 있다.
    let addSalesRecords = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        importJSONSeedDataIfNeeded()
        
        guard let tabController = window?.rootViewController as? UITabBarController,
              let employeeListNavigationController = tabController.viewControllers?[0] as? UINavigationController,
              let employeeListViewController = employeeListNavigationController.topViewController as? EmployeeListViewController else {
                fatalError("Application storyboard mis-configuration. Application is mis-configured")
        }
        
        employeeListViewController.coreDataStack = coreDataStack
        
        guard let departmentListNavigationController = tabController.viewControllers?[1] as? UINavigationController,
              let departmentListViewController = departmentListNavigationController.topViewController as? DepartmentListViewController else {
                fatalError("Application storyboard mis-configuration. Application is mis-configured")
        }
        
        departmentListViewController.coreDataStack = coreDataStack
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}

//MARK: - Data Import
extension AppDelegate {
    func importJSONSeedDataIfNeeded() {
        var importRequired = false
        
        let fetchRequest: NSFetchRequest<Employee> = NSFetchRequest(entityName: "Employee")
        var employeeCount = -1

        do {
            employeeCount = try coreDataStack.mainContext.count(for: fetchRequest)
        } catch {
            print("ERROR: count failed")
        }
        
        if employeeCount != amountToImport {
            importRequired = true
        }
        
        if !importRequired && addSalesRecords {
            let salesFetch: NSFetchRequest<Sale> = NSFetchRequest(entityName: "Sale")
            var salesCount = -1
            
            do {
                salesCount = try coreDataStack.mainContext.count(for: salesFetch)
            } catch {
                
            }
            
            if salesCount == 0 {
                importRequired = true
            }
        }
        
        if importRequired {
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Employee")) //캐싱
            deleteRequest.resultType = .resultTypeCount
            
            let deletedObjectCount: Int
            
            do {
                let resultBox = try coreDataStack.mainContext.execute(deleteRequest) as! NSBatchDeleteResult
                deletedObjectCount = resultBox.result as! Int
            } catch {
                let error = error as NSError
                print("Error: \(error.localizedDescription)")
                abort()
            }
            
            print("Removed \(deletedObjectCount) objects.")
            coreDataStack.saveContext()
            let records = max(0, min(500, amountToImport))
            importJSONSeedData(records)
        }
    }
    
    func importJSONSeedData(_ records: Int) {
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = try! Data(contentsOf: jsonURL)
        
        var jsonArray: [[String: AnyObject]] = []
        do {
            jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String: AnyObject]]
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
            abort()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var counter = 0
        for jsonDictionary in jsonArray {
            counter += 1
            
            let guid = jsonDictionary["guid"] as! String
            let active = jsonDictionary["active"] as! Bool
            let name = jsonDictionary["name"] as! String
            let vacationDays = jsonDictionary["vacationDays"] as! Int
            let department = jsonDictionary["department"] as! String
            let startDate = jsonDictionary["startDate"] as! String
            let email = jsonDictionary["email"] as! String
            let phone = jsonDictionary["phone"] as! String
            let address = jsonDictionary["address"] as! String
            let about = jsonDictionary["about"] as! String
            let picture = jsonDictionary["picture"] as! String
            let pictureComponents = picture.components(separatedBy: ".")
            let pictureFileName = pictureComponents[0]
            let pictureFileExtension = pictureComponents[1]
            let pictureURL = Bundle.main.url(forResource: pictureFileName, withExtension: pictureFileExtension)!
            let pictureData = try! Data(contentsOf: pictureURL)
            
            let employee = Employee(context: coreDataStack.mainContext)
            employee.guid = guid
            employee.active = NSNumber(value: active)
            employee.name = name
            employee.vacationDays = NSNumber(value: vacationDays)
            employee.department = department
            employee.startDate = dateFormatter.date(from: startDate)!
            employee.email = email
            employee.phone = phone
            employee.address = address
            employee.about = about
            employee.pictureThumbnail = imageDataScaledToHeight(pictureData, height: 120) //작은 크기의 섬네일을 저장
            
            let pictureObject = EmployeePicture(context: coreDataStack.mainContext) //여기에는 원본을 저장
            pictureObject.picture = pictureData
            employee.picture = pictureObject //EmployeePicture로 relationship
            
            if addSalesRecords {
                addSalesRecordsToEmployee(employee)
            }
            
            if counter == records {
                break
            }
            
            if counter % 20 == 0 {
                coreDataStack.saveContext()
                coreDataStack.mainContext.reset()
            }
        }
        
        coreDataStack.saveContext()
        coreDataStack.mainContext.reset()
        print("Imported \(counter) employees.")
    }
    
    func imageDataScaledToHeight(_ imageData: Data, height: CGFloat) -> Data { //실시간으로 이미지 변환하는데 생각보다 메모리 크게 잡아 먹진 않는다.
        let image = UIImage(data: imageData)!
        let oldHeight = image.size.height
        let scaleFactor = height / oldHeight
        let newWidth = image.size.width * scaleFactor
        let newSize = CGSize(width: newWidth, height: height)
        let newRect = CGRect(x: 0, y: 0, width: newWidth, height: height)
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: newRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIImageJPEGRepresentation(newImage!, 0.8)!
    }
    
    func addSalesRecordsToEmployee(_ employee: Employee) {
        let numberOfSales = 1000 + arc4random_uniform(5000)
        for _ in 0...numberOfSales {
            let sale = Sale(context: coreDataStack.mainContext)
            sale.employee = employee
            sale.amount = NSNumber(value: 3000 + arc4random_uniform(20000))
        }
        
        print("added \(employee.sales.count) sales")
    }
}
