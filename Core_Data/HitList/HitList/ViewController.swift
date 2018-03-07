//
//  ViewController.swift
//  HitList
//
//  Created by 근성가이 on 2018. 3. 7..
//  Copyright © 2018년 근성가이. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var people: [NSManagedObject] = [] //저장 가변 배열. Person 엔티티를 저장
    //NSManagedObject는 CoreData에 저장된 단일 객체를 나타낸다. //생성, 편집, 저장, 삭제에 이용할 수 있다.
    
    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell") //테이블 뷰 셀 등록
        //테이블 셀을 만들 때 사용할 클래스를 등록한다.
        //ReuseIdentifier가 dequeue 메서드에서 올바른 유형의 셀을 반환할 것을 보장한다.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            //appDelegate에서 직접 접근해서 가져오는 모델 보다, 앱 시작 시, DI를 통해 넘겨주는 것이 더 나은 모델
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        //검색이나 저장을 위해 NSManagedObjectContext를 이용해야 한다.
        //viewContext : NSManagedObjectContext로 CoreData를 직접 관리하는 객체(read-only).
        //persistentContainer : NSPersistentContainer로 CoreData의 컨테이너 객체
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person") //제네릭
        //<NSManagedObject>부분이 제네릭. NSManagedObject은 예상 반환형
        //NSFetchRequest : CoreData 검색에 사용. CoreData에서 객체를 선택하고 정렬하는 기준을 정할 수 있다.
        //(entityName :)으로 초기화하면 특정 엔티티의 모든 객체를 가져온다. //NSEntityDescription로 조건을 세분화할 수 있다.

        do {
            people = try managedContext.fetch(fetchRequest) //fetchRequest 요건에 충족하는 객체 배열 반환
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}

//MARK: - privateMethods
extension ViewController {
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            //appDelegate에서 직접 접근해서 가져오는 모델 보다, 앱 시작 시, DI를 통해 넘겨주는 것이 더 나은 모델
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        //검색이나 저장을 위해 NSManagedObjectContext를 이용해야 한다.
        //viewContext : NSManagedObjectContext로 CoreData를 직접 관리하는 객체(read-only).
        //persistentContainer : NSPersistentContainer로 CoreData의 컨테이너 객체
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        //CoreData 엔티티 생성. //NSManagedObject는 임의의 엔티티를 나타낼 수 있다.
        //NSEntityDescription : CoreData 엔티티에 대한 설명. CoreData의 특정 클래스와 연결
        //NSEntityDescription으로 런타임 시 데이터 모델의 엔티티의 정의를 NSManagedObject와 연결해 가져온다.
        let person = NSManagedObject(entity: entity, insertInto: managedContext) //인스턴스 생성
        person.setValue(name, forKeyPath: "name") //managedContext에 attribute 추가
        
        do {
            try managedContext.save() //CoreData에 변경 사항 저장
            
            people.append(person) //View에 나타내기 위해 업데이트
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

//MARK: - Actions
extension ViewController {
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            //stong reference를 막기 위해 unowned으로 self 값을 캡쳐한다.
            //unowned도 weak과 비슷하지만, unowned는 항상 값을 가지고 있어야 한다.
            //클로저 내부에서 self가 nil이 될 수 있으면 weak. 절대로 nil이 될 수 없다면 unowned
            //unowned는 weak 처럼 레퍼런스 카운트에 영향을 주지 않는 참조를 만든다.
            //메모리에서 해제될 때 weak은 nil이 되고(optional), unowned는 값의 변화가 없다(non- optional).
            //https://outofbedlam.github.io/swift/2016/01/31/Swift-ARC-Closure-weakself/
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return //텍스트 필드에 값이 없으면 반환
            }
            
            self.save(name: nameToSave)
            self.tableView.reloadData() //테이블 뷰 리로드
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField() //alert에 텍스트 필드를 추가한다. //여러번 입력하면 여러 개의 텍스트 필드가 추가
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
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
        //Custom cell에서만. Static에서는 withIdentifier 파라미터만 있고, indexPath 없이
        cell.textLabel?.text = person.value(forKey: "name") as? String //people의 name
        //NSManagedObject는 데이터 모델의 name 속성을 알 수 없으므로 직접 엑서스 할 수 없다.
        //CoreData가 값을 읽는 유일한 방법은 KVC(key-value coding)
        //KVC는 Foundation의 매커니즘이다. 딕셔너리와 비슷하게 작동한다.
        //KVC는 NSObject를 상속한 모든 클래스에서 사용가능하다. Swift 자체 객체에서는 기본적으로는 KVC를 사용할 수 없다.
        
        return cell
    }
}

//Navigation Controller의 navigation bar에서 Prefers Large Titles로 큰 타이틀을 설정해 줄 수 있다.

//UITableViewController를 상속 받는 것이 아니라, 직접 UITableView를 추가한 경우에는 delegate와 dataSource를 연결시켜 줘야한다.

//CoreData는 SQLite 데이터베이스를 사용한다. 데이터 모델을 스키마로 생각할 수 있다.
//클래스 이름에 managed가 있으면 CoreData 클래스를 처리한다.
//Managed는 CoreData가 수명 주기를 관리한다.

//xcdatamodeld
//entity : CoreData 클래스. 관계형 데이터 베이스의 Table에 해당. ex) 직원, 회사 등
//attribute : 특정 개체의 정보. 관계형 데이터 베이스의 Field에 해당. ex)Employee 엔티티의 이름, 직위, 급여 등
//relationship : 엔티티 간의 연결. 1:1, 1:n. ex)관리자 -> 직원 = to-many, 직원 -> 관리자 = to-one
