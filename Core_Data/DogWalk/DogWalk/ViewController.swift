//
//  ViewController.swift
//  DogWalk
//
//  Created by 근성가이 on 2016. 12. 31..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //MARK: - properties
    @IBOutlet var tableView: UITableView!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    var walks: [NSDate] = []

    var managedContext: NSManagedObjectContext!
    var currentDog: Dog?
}

//MARK: - ViewLifeCycle
extension ViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let dogName = "Fido"
        let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName) //필터링
        
        do { //Find or Create Pattern
            let results = try managedContext.fetch(dogFetch)
            if results.count > 0 {
                //Fido found, create Fido
                currentDog = results.first //하나만 찾으므로
            } else { //처음 앱을 실행한 경우
                //Fido not found, create Fido
                currentDog = Dog(context: managedContext)
                currentDog?.name = dogName
                try? managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - Actions
extension ViewController {
    @IBAction func add(_ sender: UIBarButtonItem) {
        // Insert a new Walk entity into Core Data
        let walk = Walk(context: managedContext) //새로운 Walk 오브젝트 생성
        walk.date = NSDate() //현재 시간 설정
        
        // Insert the new Walk into the Dog's walks set
        if let dog = currentDog, let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet { //NSOrderedSet이 immutable이므로 단순히 add가 아니라 복사해서 새로 넣어줘야 한다.
            walks.add(walk)
            dog.walks = walks
        }
        
//        currentDog?.addToWalks(walk) // if let 대신에 subclassing 하면서 만들어진 메서드를 이용할 수도 있다.
        
        // Save the managed object context
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Save error: \(error), description: \(error.userInfo)")
        }
        
        // Reload table view
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walks = currentDog?.walks else {
            return 1
        }
        
        return walks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let walk = currentDog?.walks?[indexPath.row] as? Walk, let walkDate = walk.date as? Date else {
            return cell
        }
        
        cell.textLabel?.text = dateFormatter.string(from: walkDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of Walks"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { //true로 하면 스와이프로 삭제버튼 생긴다.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //edit가 완료되었을 시에 호출
        guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk, editingStyle == .delete else {
            return
        }
        
        managedContext.delete(walkToRemove) //관계가 연결된 경우 삭제 시에 값이 누락 될 염려가 있다. 하지만 iOS9부터는 shouldDeleteInaccessibleFaults 프로퍼티로 관리가능. 누락된 값을 삭제한 것으로 표시하고 NULL / nil / 0 으로 처리한다.
        
        do {
            try managedContext.save()
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("Saving error: \(error), description: \(error.userInfo)")
        }
    }
}

