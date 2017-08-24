//
//  ViewController.swift
//  HitList
//
//  Created by 근성가이 on 2016. 12. 19..
//  Copyright © 2016년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController { //셀을 선택해도 아무런 이벤트가 일어나지 않으므로 DataSource 외에  UITableViewDelegate를 설정할 필요는 없다.
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
}

//MARK: - ViewLifeCycle
extension ViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person") //제네릭, Person 엔티티 전부 불러옴
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
}

//MARK: - Actions
extension ViewController {
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in //action이 떠 있는 동안 self가 nil이 될 수 없으니? //unowned 참조 :: 참조하는 대상이 초기화된 후 nil이 될 일이 없을 때 사용. non-optional. 신용카드 - 사용자 //weak 참조 :: 참조하는 대상이 살아있는 동안  nil이 될 수도 있을 때 사용. nil이 참조될 수 있으니 반드시 optional로 선언해야 한다. 도중에 nil이 들어올 수 있으니 반드시 변수로 선언해야 한다. 아파트 - 세입자
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) //handler 클로저가 필요 없으면 그냥 이런 식으로 생략해서 써도 된다.
        
        alert.addTextField() //텍스트 필드 여러 개를 입력할 수 있다. //handler 클로저가 필요 없으면 그냥 이런 식으로 생략해서 써도 된다.
        alert.addAction(saveAction) //handler 클로저가 필요 없으면 그냥 이런 식으로 생략해서 써도 된다.
        alert.addAction(cancelAction) //handler 클로저가 필요 없으면 그냥 이런 식으로 생략해서 써도 된다.
        
        present(alert, animated: true) //handler 클로저가 필요 없으면 그냥 이런 식으로 생략해서 써도 된다.
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { //앱 델리게이트 가져오기. DI로 바꾸는 게 좋을 듯?
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext //NSManagedObjectContext를 먼저 불러와야 한다.
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)! //NSEntityDescription은 런타임시 데이터 모델의 엔티티 정의를 NSManagedObject의 인스턴스와 연결하는 부분.
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        person.setValue(name, forKey: "name") //KVC
    
        do {
            try managedContext.save() //컨텍스트를 저장한다.
            people.append(person)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKey: "name") as? String //Key-Value Coding //KVC는 NSOnject를 상속한 클래스이면 사용할 수 있다. //스위프트 클래스는 기본적으로 최상위 NSObject를 상속하지 않아도 되기 때문에 상속해 줘야. //NSManagedObject는 NSObject를 상속
        
        return cell
    }
}

